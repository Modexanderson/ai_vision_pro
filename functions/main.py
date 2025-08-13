import os
import json
import requests
import logging
from datetime import datetime, timedelta
import firebase_functions
from firebase_admin import initialize_app, firestore
from firebase_admin import credentials
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Initialize Firebase
cred = credentials.ApplicationDefault()
initialize_app(cred)
db = firestore.client()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constants
ANDROID_PACKAGE_NAME = "com.aivisionpro.app"
IOS_BUNDLE_ID = "com.aivisionpro.app"
GOOGLE_PLAY_SCOPES = ['https://www.googleapis.com/auth/androidpublisher']
APPLE_VERIFICATION_URL = "https://buy.itunes.apple.com/verifyReceipt"
APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"

# Product IDs
PRODUCT_IDS = {
    "monthly": {
        "android": "monthly_premium",
        "ios": "ai_vision_pro_monthly"
    },
    "yearly": {
        "android": "yearly_premium",
        "ios": "ai_vision_pro_yearly"
    },
    "lifetime": {
        "android": "lifetime_premium",
        "ios": "ai_vision_pro_lifetime"
    }
}

def get_google_play_service():
    """Initialize Google Play Developer API service with retry logic"""
    max_retries = 3
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            # credentials = service_account.Credentials.from_service_account_info(
            #     json.loads(os.environ.get('GOOGLE_SERVICE_ACCOUNT')),
            #     scopes=GOOGLE_PLAY_SCOPES
            # )
            config = firebase_functions.config()
            google_sa = config["google"]["service_account"]
            credentials = service_account.Credentials.from_service_account_info(
                google_sa,
                scopes=GOOGLE_PLAY_SCOPES
            )
            return build('androidpublisher', 'v3', credentials=credentials)
        except Exception as e:
            retry_count += 1
            logger.error(f"Failed to initialize Google Play service (attempt {retry_count}): {str(e)}")
            if retry_count == max_retries:
                raise Exception("Failed to initialize Google Play service after multiple attempts")

def verify_ios_receipt(receipt_data):
    """Verify iOS App Store receipt with Apple's servers"""
    try:
        # First try production environment
        payload = {
            'receipt-data': receipt_data.get('receipt'),
            'password': os.environ.get('IOS_SHARED_SECRET'),
            'exclude-old-transactions': True
        }
        
        response = requests.post(
            APPLE_VERIFICATION_URL,
            json=payload,
            timeout=10
        ).json()
        
        # If this is a sandbox receipt, try sandbox environment
        if response.get('status') == 21007:
            response = requests.post(
                APPLE_SANDBOX_URL,
                json=payload,
                timeout=10
            ).json()
        
        if response.get('status') != 0:
            logger.error(f"iOS receipt verification failed with status: {response.get('status')}")
            return None
        
        return response
    except requests.exceptions.RequestException as e:
        logger.error(f"Network error during iOS receipt verification: {str(e)}")
        return None
    except Exception as e:
        logger.error(f"iOS receipt verification failed: {str(e)}")
        return None

def verify_android_purchase(purchase_token, product_id):
    """Verify Android in-app purchase with Google Play with retry logic"""
    max_retries = 3
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            service = get_google_play_service()
            result = service.purchases().subscriptions().get(
                packageName=ANDROID_PACKAGE_NAME,
                subscriptionId=product_id,
                token=purchase_token
            ).execute()
            
            # Validate the purchase
            if not result.get('orderId'):
                logger.error("Android purchase verification failed: No order ID in response")
                return None
                
            return result
            
        except HttpError as e:
            if e.resp.status == 410:  # Subscription expired
                logger.info(f"Android subscription expired for product {product_id}")
                return None
            retry_count += 1
            logger.error(f"Android purchase verification failed (attempt {retry_count}): {str(e)}")
            if retry_count == max_retries:
                return None
        except Exception as e:
            retry_count += 1
            logger.error(f"Android purchase verification failed (attempt {retry_count}): {str(e)}")
            if retry_count == max_retries:
                return None

def save_subscription_to_firestore(user_id, subscription_data):
    """Save subscription details to Firestore with transaction"""
    try:
        @firestore.transactional
        def update_in_transaction(transaction, subscription_ref):
            snapshot = subscription_ref.get(transaction=transaction)
            existing_data = snapshot.to_dict() or {}
            
            # Preserve original purchase date if this is an update
            if 'purchaseDate' in existing_data:
                subscription_data['purchaseDate'] = existing_data['purchaseDate']
            
            subscription_data['lastValidated'] = firestore.SERVER_TIMESTAMP
            subscription_data['updatedAt'] = firestore.SERVER_TIMESTAMP
            
            transaction.set(subscription_ref, subscription_data, merge=True)
        
        subscription_ref = db.collection('subscriptions').document(user_id)
        db.run_transaction(lambda t: update_in_transaction(t, subscription_ref))
        
        logger.info(f"Subscription saved for user {user_id}")
        return True
    except Exception as e:
        logger.error(f"Failed to save subscription: {str(e)}")
        return False

def process_ios_subscription(user_id, receipt_data):
    """Process iOS subscription purchase with full validation"""
    verification_result = verify_ios_receipt(receipt_data)
    
    if not verification_result or verification_result.get('status') != 0:
        logger.error("iOS receipt verification failed")
        return False
    
    receipt = verification_result.get('receipt', {})
    latest_receipt_info = receipt.get('latest_receipt_info', [{}])[-1]
    
    product_id = latest_receipt_info.get('product_id')
    transaction_id = latest_receipt_info.get('transaction_id')
    purchase_date = datetime.fromtimestamp(int(latest_receipt_info.get('purchase_date_ms', 0)) / 1000)
    expiry_date = datetime.fromtimestamp(int(latest_receipt_info.get('expires_date_ms', 0)) / 1000)
    
    # Determine plan type
    plan_type = "monthly"
    if product_id == PRODUCT_IDS["yearly"]["ios"]:
        plan_type = "yearly"
    elif product_id == PRODUCT_IDS["lifetime"]["ios"]:
        plan_type = "lifetime"
    
    subscription_data = {
        'userId': user_id,
        'productId': product_id,
        'transactionId': transaction_id,
        'purchaseDate': purchase_date,
        'expiryDate': expiry_date if plan_type != "lifetime" else None,
        'isActive': True,
        'platform': 'ios',
        'planType': plan_type,
        'originalTransactionId': latest_receipt_info.get('original_transaction_id'),
        'verificationData': json.dumps(verification_result),
        'latestReceipt': receipt.get('latest_receipt')  # For future validations
    }
    
    return save_subscription_to_firestore(user_id, subscription_data)

def process_android_subscription(user_id, purchase_token, product_id):
    """Process Android subscription purchase with full validation"""
    verification_result = verify_android_purchase(purchase_token, product_id)
    
    if not verification_result:
        logger.error("Android purchase verification failed")
        return False
    
    # Determine plan type
    plan_type = "monthly"
    if product_id == PRODUCT_IDS["yearly"]["android"]:
        plan_type = "yearly"
    elif product_id == PRODUCT_IDS["lifetime"]["android"]:
        plan_type = "lifetime"
    
    start_time = datetime.fromtimestamp(int(verification_result.get('startTimeMillis', 0)) / 1000)
    expiry_time = datetime.fromtimestamp(int(verification_result.get('expiryTimeMillis', 0)) / 1000)
    
    subscription_data = {
        'userId': user_id,
        'productId': product_id,
        'transactionId': verification_result.get('orderId'),
        'purchaseDate': start_time,
        'expiryDate': expiry_time if plan_type != "lifetime" else None,
        'isActive': verification_result.get('paymentState') == 1,  # 1 means payment received
        'platform': 'android',
        'planType': plan_type,
        'verificationData': json.dumps(verification_result),
        'purchaseToken': purchase_token  # For future validations
    }
    
    return save_subscription_to_firestore(user_id, subscription_data)

def validate_existing_subscription(user_id):
    """Validate an existing subscription with platform-specific checks"""
    try:
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription = subscription_ref.get().to_dict()
        
        if not subscription:
            logger.error(f"No subscription found for user {user_id}")
            return False
        
        platform = subscription.get('platform')
        is_active = subscription.get('isActive', False)
        
        # Check if subscription is already marked inactive
        if not is_active:
            return False
        
        # Check if lifetime subscription
        if subscription.get('planType') == 'lifetime':
            return True
        
        # Check if expired
        expiry_date = subscription.get('expiryDate')
        if expiry_date and expiry_date < datetime.now():
            subscription_ref.update({'isActive': False, 'cancelledAt': firestore.SERVER_TIMESTAMP})
            return False
        
        # For active subscriptions, verify with platform
        if platform == 'ios':
            verification_data = json.loads(subscription.get('verificationData', '{}'))
            latest_receipt = subscription.get('latestReceipt')
            if not latest_receipt:
                return False
                
            # Re-verify with Apple
            verification_result = verify_ios_receipt({'receipt': latest_receipt})
            if not verification_result or verification_result.get('status') != 0:
                subscription_ref.update({'isActive': False, 'cancelledAt': firestore.SERVER_TIMESTAMP})
                return False
            return True
            
        elif platform == 'android':
            verification_data = json.loads(subscription.get('verificationData', '{}'))
            product_id = subscription.get('productId')
            purchase_token = subscription.get('purchaseToken')
            
            if not product_id or not purchase_token:
                return False
                
            # Re-verify with Google Play
            verification_result = verify_android_purchase(purchase_token, product_id)
            if not verification_result:
                subscription_ref.update({'isActive': False, 'cancelledAt': firestore.SERVER_TIMESTAMP})
                return False
            return True
        
        return False
    except Exception as e:
        logger.error(f"Subscription validation failed: {str(e)}")
        return False

# HTTP Triggered Functions
def process_subscription(request):
    """HTTP Cloud Function to process new subscriptions"""
    if request.method != 'POST':
        return {'success': False, 'error': 'Method not allowed'}, 405
    
    try:
        data = request.get_json()
        if not data:
            return {'success': False, 'error': 'No data provided'}, 400
            
        user_id = data.get('userId')
        platform = data.get('platform')
        purchase_data = data.get('purchaseData')
        
        if not user_id or not platform or not purchase_data:
            return {'success': False, 'error': 'Missing required fields'}, 400
        
        success = False
        
        if platform == 'ios':
            success = process_ios_subscription(user_id, purchase_data)
        elif platform == 'android':
            product_id = data.get('productId')
            purchase_token = purchase_data.get('purchaseToken')
            if not product_id or not purchase_token:
                return {'success': False, 'error': 'Missing productId or purchaseToken'}, 400
            success = process_android_subscription(user_id, purchase_token, product_id)
        else:
            return {'success': False, 'error': 'Invalid platform'}, 400
        
        if success:
            return {'success': True, 'message': 'Subscription processed successfully'}, 200
        else:
            return {'success': False, 'error': 'Failed to process subscription'}, 500
    
    except Exception as e:
        logger.error(f"Error processing subscription: {str(e)}")
        return {'success': False, 'error': str(e)}, 500

def validate_subscription(request):
    """HTTP Cloud Function to validate existing subscription"""
    if request.method != 'POST':
        return {'success': False, 'error': 'Method not allowed'}, 405
    
    try:
        data = request.get_json()
        if not data:
            return {'success': False, 'error': 'No data provided'}, 400
            
        user_id = data.get('userId')
        
        if not user_id:
            return {'success': False, 'error': 'Missing userId'}, 400
        
        is_valid = validate_existing_subscription(user_id)
        
        return {
            'success': True,
            'isValid': is_valid,
            'message': 'Subscription validated successfully'
        }, 200
    
    except Exception as e:
        logger.error(f"Error validating subscription: {str(e)}")
        return {'success': False, 'error': str(e)}, 500

# Firebase Triggers
def on_user_create(user, context):
    """Triggered when a new user is created"""
    try:
        user_id = user.uid
        logger.info(f"New user created: {user_id}")
        
        # Initialize user document with transaction
        @firestore.transactional
        def create_user_in_transaction(transaction, user_ref):
            snapshot = user_ref.get(transaction=transaction)
            if snapshot.exists:
                return
                
            transaction.set(user_ref, {
                'createdAt': firestore.SERVER_TIMESTAMP,
                'lastLogin': firestore.SERVER_TIMESTAMP,
                'preferences': {
                    'theme': 'system',
                    'notifications': True,
                    'language': 'en'
                },
                'stats': {
                    'totalScans': 0,
                    'totalImages': 0,
                    'favoriteCount': 0
                }
            })
        
        user_ref = db.collection('users').document(user_id)
        db.run_transaction(lambda t: create_user_in_transaction(t, user_ref))
        
    except Exception as e:
        logger.error(f"Error handling new user: {str(e)}")

def on_subscription_update(change, context):
    """Triggered when a subscription is updated"""
    try:
        before_data = change.before.to_dict() if change.before.exists else {}
        after_data = change.after.to_dict()
        
        user_id = after_data.get('userId')
        is_active = after_data.get('isActive')
        
        # Check if subscription status changed
        if before_data.get('isActive') != is_active:
            logger.info(f"Subscription status changed for user {user_id}: isActive={is_active}")
            
            # Update user's premium status with transaction
            @firestore.transactional
            def update_user_in_transaction(transaction, user_ref):
                transaction.update(user_ref, {
                    'isPremium': is_active,
                    'premiumSince': firestore.SERVER_TIMESTAMP if is_active else None,
                    'premiumPlan': after_data.get('planType') if is_active else None
                })
            
            user_ref = db.collection('users').document(user_id)
            db.run_transaction(lambda t: update_user_in_transaction(t, user_ref))
            
            # Log the subscription event
            db.collection('subscriptionEvents').add({
                'userId': user_id,
                'eventType': 'status_change',
                'newStatus': is_active,
                'planType': after_data.get('planType'),
                'timestamp': firestore.SERVER_TIMESTAMP
            })
    except Exception as e:
        logger.error(f"Error handling subscription update: {str(e)}")

def cancel_subscription(user_id):
    """Cancel a user's subscription with proper validation"""
    try:
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription = subscription_ref.get().to_dict()
        
        if not subscription:
            return {'success': False, 'error': 'No subscription found'}
        
        # Mark as cancelled in Firestore
        subscription_ref.update({
            'isActive': False,
            'cancelledAt': firestore.SERVER_TIMESTAMP,
            'cancelledBy': 'user'  # Could be 'system' or 'admin' in other cases
        })
        
        return {'success': True, 'message': 'Subscription cancelled'}
    except Exception as e:
        logger.error(f"Error cancelling subscription: {str(e)}")
        return {'success': False, 'error': str(e)}

def get_subscription_status(user_id):
    """Get subscription status for a user with full validation"""
    try:
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription = subscription_ref.get().to_dict()
        
        if not subscription:
            return {
                'success': True,
                'hasSubscription': False,
                'isActive': False
            }
        
        # Check if expired
        is_active = subscription.get('isActive', False)
        expiry_date = subscription.get('expiryDate')
        
        if expiry_date and expiry_date < datetime.now():
            is_active = False
            subscription_ref.update({'isActive': False})
        
        return {
            'success': True,
            'hasSubscription': True,
            'isActive': is_active,
            'planType': subscription.get('planType'),
            'expiryDate': expiry_date.isoformat() if expiry_date else None,
            'purchaseDate': subscription.get('purchaseDate').isoformat() if subscription.get('purchaseDate') else None,
            'platform': subscription.get('platform')
        }
    except Exception as e:
        logger.error(f"Error getting subscription status: {str(e)}")
        return {'success': False, 'error': str(e)}