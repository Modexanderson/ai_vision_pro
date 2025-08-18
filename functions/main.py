import os
import json
import logging
from datetime import datetime, timedelta
from firebase_functions import https_fn, firestore_fn, options
from firebase_admin import initialize_app, firestore
import dateutil.relativedelta

# Initialize Firebase App immediately
app = initialize_app()

# Configure logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Constants
ANDROID_PACKAGE_NAME = "com.aivisionpro.app"
IOS_BUNDLE_ID = "com.aivisionpro.app"
GOOGLE_PLAY_SCOPES = ['https://www.googleapis.com/auth/androidpublisher']
APPLE_VERIFICATION_URL = "https://buy.itunes.apple.com/verifyReceipt"
APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
API_LIMITS = {
    'free': {'apiCalls': 100, 'batchScans': 10},
    'monthly': {'apiCalls': 500, 'batchScans': 50},
    'yearly': {'apiCalls': 1000, 'batchScans': 100, 'early_access': True}
}
GRACE_PERIOD_DAYS = 7

# Product IDs
PRODUCT_IDS = {
    "monthly": {
        "android": "monthly_premium",
        "ios": "ai_vision_pro_monthly"
    },
    "yearly": {
        "android": "yearly_premium",
        "ios": "ai_vision_pro_yearly"
    }
}

# Global clients (lazy loaded to improve cold start performance)
_firestore_client = None
_google_play_service = None

def get_firestore_client():
    """Get Firestore client with lazy initialization"""
    global _firestore_client
    if _firestore_client is None:
        _firestore_client = firestore.client()
    return _firestore_client

def get_google_play_service():
    """Initialize Google Play Developer API service with lazy loading"""
    global _google_play_service
    if _google_play_service is not None:
        return _google_play_service
    
    try:
        # Lazy import to speed up cold starts
        from googleapiclient.discovery import build
        from google.oauth2 import service_account
        
        # Try to load from service_account.json first
        try:
            with open('service_account.json', 'r') as f:
                google_sa = json.load(f)
        except FileNotFoundError:
            # Fallback to environment variable
            google_sa_json = os.environ.get('GOOGLE_SERVICE_ACCOUNT')
            if not google_sa_json:
                logger.error("No Google service account configuration found")
                raise Exception("Google service account configuration not found")
            google_sa = json.loads(google_sa_json)
            
        credentials = service_account.Credentials.from_service_account_info(
            google_sa, scopes=GOOGLE_PLAY_SCOPES
        )
        _google_play_service = build('androidpublisher', 'v3', credentials=credentials)
        return _google_play_service
        
    except Exception as e:
        logger.error(f"Failed to initialize Google Play service: {str(e)}")
        raise

def verify_ios_receipt(receipt_data):
    """Verify iOS App Store receipt with Apple's servers"""
    try:
        # Lazy import to improve cold start
        import requests
        
        # Get iOS shared secret from environment or Firebase config
        ios_shared_secret = os.environ.get('IOS_SHARED_SECRET')
        if not ios_shared_secret:
            # Try Firebase Functions config (legacy)
            ios_shared_secret = os.environ.get('FIREBASE_CONFIG', {}).get('ios', {}).get('shared_secret')
        
        payload = {
            'receipt-data': receipt_data,
            'password': ios_shared_secret,
            'exclude-old-transactions': True
        }
        
        # Try production server first
        response = requests.post(APPLE_VERIFICATION_URL, json=payload, timeout=10).json()
        
        # If sandbox receipt, try sandbox server
        if response.get('status') == 21007:
            response = requests.post(APPLE_SANDBOX_URL, json=payload, timeout=10).json()
        
        if response.get('status') != 0:
            logger.error(f"iOS receipt verification failed with status: {response.get('status')}")
            return None
        
        return response
        
    except Exception as e:
        logger.error(f"iOS receipt verification failed: {str(e)}")
        return None

def verify_android_purchase(purchase_token, product_id):
    """Verify Android in-app purchase with Google Play"""
    try:
        from googleapiclient.errors import HttpError
        
        service = get_google_play_service()
        result = service.purchases().subscriptions().get(
            packageName=ANDROID_PACKAGE_NAME,
            subscriptionId=product_id,
            token=purchase_token
        ).execute()
        
        if not result.get('orderId'):
            logger.error("Android purchase verification failed: No order ID")
            return None
        
        return result
        
    except HttpError as e:
        if e.resp.status == 410:
            logger.info(f"Android subscription expired for product {product_id}")
            return None
        logger.error(f"Android purchase verification failed: {str(e)}")
        return None
    except Exception as e:
        logger.error(f"Android purchase verification failed: {str(e)}")
        return None

def save_subscription_to_firestore(user_id, subscription_data):
    """Save subscription details to Firestore with transaction"""
    try:
        db = get_firestore_client()
        
        @firestore.transactional
        def update_in_transaction(transaction, subscription_ref):
            snapshot = subscription_ref.get(transaction=transaction)
            existing_data = snapshot.to_dict() or {}
            
            # Preserve original purchase date if it exists
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

def process_ios_subscription(user_id, purchase_data):
    """Process iOS subscription with full validation"""
    try:
        verification_result = verify_ios_receipt(purchase_data.get('receipt'))
        
        if not verification_result or verification_result.get('status') != 0:
            logger.error("iOS receipt verification failed")
            return False
        
        receipt = verification_result.get('receipt', {})
        latest_receipt_info = receipt.get('latest_receipt_info', [{}])
        
        if not latest_receipt_info:
            logger.error("No receipt info found")
            return False
            
        latest_info = latest_receipt_info[-1]
        
        product_id = latest_info.get('product_id')
        transaction_id = latest_info.get('transaction_id')
        purchase_date_ms = latest_info.get('purchase_date_ms', '0')
        expiry_date_ms = latest_info.get('expires_date_ms', '0')
        
        purchase_date = datetime.fromtimestamp(int(purchase_date_ms) / 1000)
        expiry_date = datetime.fromtimestamp(int(expiry_date_ms) / 1000)
        
        # Determine plan type
        plan_type = "monthly"
        if product_id == PRODUCT_IDS["yearly"]["ios"]:
            plan_type = "yearly"
        
        subscription_data = {
            'userId': user_id,
            'productId': product_id,
            'transactionId': transaction_id,
            'purchaseDate': purchase_date,
            'expiryDate': expiry_date,
            'isActive': True,
            'platform': 'ios',
            'planType': plan_type,
            'originalTransactionId': latest_info.get('original_transaction_id'),
            'verificationData': json.dumps(verification_result),
            'latestReceipt': receipt.get('latest_receipt'),
            'gracePeriodUntil': (datetime.now() + timedelta(days=GRACE_PERIOD_DAYS)).isoformat()
        }
        
        return save_subscription_to_firestore(user_id, subscription_data)
        
    except Exception as e:
        logger.error(f"Error processing iOS subscription: {str(e)}")
        return False

def process_android_subscription(user_id, purchase_token, product_id):
    """Process Android subscription with full validation"""
    try:
        verification_result = verify_android_purchase(purchase_token, product_id)
        
        if not verification_result:
            logger.error("Android purchase verification failed")
            return False
        
        # Determine plan type
        plan_type = "monthly"
        if product_id == PRODUCT_IDS["yearly"]["android"]:
            plan_type = "yearly"
        
        start_time_ms = verification_result.get('startTimeMillis', '0')
        expiry_time_ms = verification_result.get('expiryTimeMillis', '0')
        
        start_time = datetime.fromtimestamp(int(start_time_ms) / 1000)
        expiry_time = datetime.fromtimestamp(int(expiry_time_ms) / 1000)
        
        subscription_data = {
            'userId': user_id,
            'productId': product_id,
            'transactionId': verification_result.get('orderId'),
            'purchaseDate': start_time,
            'expiryDate': expiry_time,
            'isActive': verification_result.get('paymentState') == 1,
            'platform': 'android',
            'planType': plan_type,
            'verificationData': json.dumps(verification_result),
            'purchaseToken': purchase_token,
            'gracePeriodUntil': (datetime.now() + timedelta(days=GRACE_PERIOD_DAYS)).isoformat()
        }
        
        return save_subscription_to_firestore(user_id, subscription_data)
        
    except Exception as e:
        logger.error(f"Error processing Android subscription: {str(e)}")
        return False

def validate_existing_subscription(user_id):
    """Validate an existing subscription with platform-specific checks"""
    try:
        db = get_firestore_client()
        
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription_doc = subscription_ref.get()
        
        if not subscription_doc.exists:
            logger.info(f"No subscription found for user {user_id}")
            return False
            
        subscription = subscription_doc.to_dict()
        
        platform = subscription.get('platform')
        is_active = subscription.get('isActive', False)
        grace_period_until = subscription.get('gracePeriodUntil')
        
        if not is_active:
            return False
        
        # Check grace period
        if grace_period_until:
            try:
                grace_date = datetime.fromisoformat(grace_period_until)
                if grace_date > datetime.now():
                    return True
            except (ValueError, TypeError):
                pass
        
        # Check expiry date
        expiry_date = subscription.get('expiryDate')
        if expiry_date and expiry_date < datetime.now():
            subscription_ref.update({
                'isActive': False, 
                'cancelledAt': firestore.SERVER_TIMESTAMP
            })
            return False
        
        # Platform-specific validation
        if platform == 'ios':
            latest_receipt = subscription.get('latestReceipt')
            if not latest_receipt:
                return False
                
            verification_result = verify_ios_receipt({'receipt': latest_receipt})
            if not verification_result or verification_result.get('status') != 0:
                subscription_ref.update({
                    'isActive': False, 
                    'cancelledAt': firestore.SERVER_TIMESTAMP
                })
                return False
                
            # Update with latest receipt info
            receipt = verification_result.get('receipt', {})
            latest_receipt_info = receipt.get('latest_receipt_info', [{}])
            if latest_receipt_info:
                latest_info = latest_receipt_info[-1]
                new_expiry_ms = latest_info.get('expires_date_ms', '0')
                new_expiry = datetime.fromtimestamp(int(new_expiry_ms) / 1000)
                
                subscription_ref.update({
                    'expiryDate': new_expiry,
                    'verificationData': json.dumps(verification_result),
                    'gracePeriodUntil': (datetime.now() + timedelta(days=GRACE_PERIOD_DAYS)).isoformat(),
                    'lastValidated': firestore.SERVER_TIMESTAMP
                })
            return True
            
        elif platform == 'android':
            product_id = subscription.get('productId')
            purchase_token = subscription.get('purchaseToken')
            
            if not product_id or not purchase_token:
                return False
                
            verification_result = verify_android_purchase(purchase_token, product_id)
            if not verification_result:
                subscription_ref.update({
                    'isActive': False, 
                    'cancelledAt': firestore.SERVER_TIMESTAMP
                })
                return False
                
            # Update with latest verification info
            new_expiry_ms = verification_result.get('expiryTimeMillis', '0')
            new_expiry = datetime.fromtimestamp(int(new_expiry_ms) / 1000)
            
            subscription_ref.update({
                'expiryDate': new_expiry,
                'verificationData': json.dumps(verification_result),
                'gracePeriodUntil': (datetime.now() + timedelta(days=GRACE_PERIOD_DAYS)).isoformat(),
                'lastValidated': firestore.SERVER_TIMESTAMP
            })
            return True
        
        return False
        
    except Exception as e:
        logger.error(f"Subscription validation failed: {str(e)}")
        return False

# HTTP Cloud Functions
@https_fn.on_request()
def health_check(request):
    """Simple health check endpoint"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    return ({
        'status': 'ok', 
        'timestamp': datetime.now().isoformat(),
        'service': 'ai-object-identifier-functions'
    }, 200, headers)

@https_fn.on_request()
def update_usage_limits(request):
    """Update and check API usage limits with monthly reset"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        if not user_id:
            return ({'success': False, 'error': 'Missing userId'}, 400, headers)
            
        requested_api_calls = data.get('apiCalls', 0)
        requested_batch_scans = data.get('batchScans', 0)
        reset_period = data.get('resetPeriod', 'monthly')

        # Get subscription info
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription = subscription_ref.get()

        if not subscription.exists:
            return ({'success': False, 'error': 'No subscription found'}, 400, headers)

        plan_type = subscription.to_dict().get('planType', 'free')

        if plan_type not in API_LIMITS:
            return ({'success': False, 'error': 'Invalid plan type'}, 400, headers)

        # Get or create usage document
        usage_ref = db.collection('usage').document(user_id)
        usage = usage_ref.get()
        usage_data = usage.to_dict() if usage.exists else {
            'apiCalls': 0,
            'batchScans': 0,
            'lastReset': datetime.now().isoformat()
        }

        # Check if reset is needed
        last_reset = datetime.fromisoformat(usage_data['lastReset'])
        now = datetime.now()
        reset_needed = (reset_period == 'monthly' and
                        now >= last_reset + dateutil.relativedelta.relativedelta(months=1))

        if reset_needed:
            usage_data = {
                'apiCalls': 0,
                'batchScans': 0,
                'lastReset': now.isoformat()
            }

        current_api_calls = usage_data['apiCalls']
        current_batch_scans = usage_data['batchScans']

        # Check limits
        limits = API_LIMITS[plan_type]
        if (current_api_calls + requested_api_calls > limits['apiCalls'] or
            current_batch_scans + requested_batch_scans > limits['batchScans']):
            return ({
                'success': False, 
                'error': 'Usage limit exceeded',
                'currentUsage': {
                    'apiCalls': current_api_calls,
                    'batchScans': current_batch_scans
                },
                'limits': limits
            }, 403, headers)

        # Update usage
        usage_data['apiCalls'] += requested_api_calls
        usage_data['batchScans'] += requested_batch_scans
        usage_ref.set(usage_data, merge=True)

        return ({'success': True, 'usage': usage_data}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error updating usage limits: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def get_usage(request):
    """Get current usage data for a user"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        if not user_id:
            return ({'success': False, 'error': 'Missing userId'}, 400, headers)
            
        usage_ref = db.collection('usage').document(user_id)
        usage = usage_ref.get()
        
        if usage.exists:
            usage_data = usage.to_dict()
            return ({
                'success': True,
                'apiCalls': usage_data.get('apiCalls', 0),
                'batchScans': usage_data.get('batchScans', 0),
                'lastReset': usage_data.get('lastReset', datetime.now().isoformat())
            }, 200, headers)
        
        return ({
            'success': True,
            'apiCalls': 0,
            'batchScans': 0,
            'lastReset': datetime.now().isoformat()
        }, 200, headers)
        
    except Exception as e:
        logger.error(f"Error getting usage: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def process_subscription(request):
    """HTTP Cloud Function to process new subscriptions"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        platform = data.get('platform')
        purchase_data = data.get('purchaseData')
        
        if not user_id or not platform or not purchase_data:
            return ({'success': False, 'error': 'Missing required fields'}, 400, headers)
        
        success = False
        
        if platform == 'ios':
            success = process_ios_subscription(user_id, purchase_data)
        elif platform == 'android':
            product_id = data.get('productId')
            purchase_token = purchase_data.get('purchaseToken')
            if not product_id or not purchase_token:
                return ({'success': False, 'error': 'Missing productId or purchaseToken'}, 400, headers)
            success = process_android_subscription(user_id, purchase_token, product_id)
        else:
            return ({'success': False, 'error': 'Invalid platform'}, 400, headers)
        
        if success:
            return ({'success': True, 'message': 'Subscription processed successfully'}, 200, headers)
        else:
            return ({'success': False, 'error': 'Failed to process subscription'}, 500, headers)
    
    except Exception as e:
        logger.error(f"Error processing subscription: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def validate_subscription(request):
    """HTTP Cloud Function to validate existing subscription"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        
        if not user_id:
            return ({'success': False, 'error': 'Missing userId'}, 400, headers)
        
        is_valid = validate_existing_subscription(user_id)
        
        return ({
            'success': True,
            'isValid': is_valid,
            'message': 'Subscription validated successfully'
        }, 200, headers)
    
    except Exception as e:
        logger.error(f"Error validating subscription: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def get_subscription_status(request):
    """HTTP Cloud Function to get subscription status"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        
        if not user_id:
            return ({'success': False, 'error': 'Missing userId'}, 400, headers)
        
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription_doc = subscription_ref.get()
        
        if not subscription_doc.exists:
            return ({
                'success': True,
                'hasSubscription': False,
                'isActive': False
            }, 200, headers)
        
        subscription = subscription_doc.to_dict()
        is_active = subscription.get('isActive', False)
        expiry_date = subscription.get('expiryDate')
        
        # Check if expired
        if expiry_date and expiry_date < datetime.now():
            is_active = False
            subscription_ref.update({'isActive': False})
        
        return ({
            'success': True,
            'hasSubscription': True,
            'isActive': is_active,
            'planType': subscription.get('planType'),
            'expiryDate': expiry_date.isoformat() if expiry_date else None,
            'purchaseDate': subscription.get('purchaseDate').isoformat() if subscription.get('purchaseDate') else None,
            'platform': subscription.get('platform')
        }, 200, headers)
        
    except Exception as e:
        logger.error(f"Error getting subscription status: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def cancel_subscription(request):
    """HTTP Cloud Function to cancel a user's subscription"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        
        if not user_id:
            return ({'success': False, 'error': 'Missing userId'}, 400, headers)
        
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription_doc = subscription_ref.get()
        
        if not subscription_doc.exists:
            return ({'success': False, 'error': 'No subscription found'}, 404, headers)
        
        subscription_ref.update({
            'isActive': False,
            'cancelledAt': firestore.SERVER_TIMESTAMP,
            'cancelledBy': 'user'
        })
        
        return ({'success': True, 'message': 'Subscription cancelled'}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error cancelling subscription: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def webhook_subscription_update(request):
    """Handle subscription updates from Apple/Google webhooks"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        platform = data.get('platform')
        user_id = data.get('userId')
        
        if not platform or not user_id:
            return ({'success': False, 'error': 'Missing platform or userId'}, 400, headers)
        
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription_doc = subscription_ref.get()
        
        if not subscription_doc.exists:
            return ({'success': False, 'error': 'No subscription found'}, 404, headers)
        
        if platform == 'ios':
            notification_type = data.get('notificationType')
            latest_receipt = data.get('latest_receipt')
            
            verification_result = verify_ios_receipt({'receipt': latest_receipt})
            
            if not verification_result or verification_result.get('status') != 0:
                subscription_ref.update({
                    'isActive': False, 
                    'cancelledAt': firestore.SERVER_TIMESTAMP
                })
                return ({'success': True, 'message': 'Subscription cancelled'}, 200, headers)
                
            receipt = verification_result.get('receipt', {})
            latest_receipt_info = receipt.get('latest_receipt_info', [{}])
            if latest_receipt_info:
                latest_info = latest_receipt_info[-1]
                new_expiry_ms = latest_info.get('expires_date_ms', '0')
                new_expiry = datetime.fromtimestamp(int(new_expiry_ms) / 1000)
            
                subscription_ref.update({
                    'isActive': notification_type in ['RENEWAL', 'INITIAL_BUY'],
                    'expiryDate': new_expiry if notification_type != 'CANCEL' else None,
                    'verificationData': json.dumps(verification_result),
                    'latestReceipt': latest_receipt,
                    'gracePeriodUntil': (datetime.now() + timedelta(days=GRACE_PERIOD_DAYS)).isoformat()
                })
            
        elif platform == 'android':
            purchase_token = data.get('purchaseToken')
            product_id = data.get('productId')
            event_type = data.get('eventType')
            
            verification_result = verify_android_purchase(purchase_token, product_id)
            if not verification_result:
                subscription_ref.update({
                    'isActive': False, 
                    'cancelledAt': firestore.SERVER_TIMESTAMP
                })
                return ({'success': True, 'message': 'Subscription cancelled'}, 200, headers)
                
            new_expiry_ms = verification_result.get('expiryTimeMillis', '0')
            new_expiry = datetime.fromtimestamp(int(new_expiry_ms) / 1000)
            
            subscription_ref.update({
                'isActive': event_type in ['SUBSCRIPTION_RENEWED', 'SUBSCRIPTION_PURCHASED'],
                'expiryDate': new_expiry,
                'verificationData': json.dumps(verification_result),
                'purchaseToken': purchase_token,
                'gracePeriodUntil': (datetime.now() + timedelta(days=GRACE_PERIOD_DAYS)).isoformat()
            })
        
        return ({'success': True, 'message': 'Webhook processed'}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error processing webhook: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

# Firestore Triggers
@firestore_fn.on_document_created(document="users/{userId}")
def on_user_create(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]):
    """Triggered when a new user is created"""
    try:
        db = get_firestore_client()
        
        user_id = event.params['userId']
        logger.info(f"New user created: {user_id}")
        
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
            }, merge=True)
        
        user_ref = db.collection('users').document(user_id)
        db.run_transaction(lambda t: create_user_in_transaction(t, user_ref))
        
    except Exception as e:
        logger.error(f"Error handling new user: {str(e)}")

@firestore_fn.on_document_updated(document="subscriptions/{userId}")
def on_subscription_update(event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot]]):
    """Triggered when a subscription is updated"""
    try:
        db = get_firestore_client()
        
        before_data = event.data.before.to_dict() if event.data.before.exists else {}
        after_data = event.data.after.to_dict()
        
        user_id = after_data.get('userId')
        is_active = after_data.get('isActive')
        
        # Only update if status changed
        if before_data.get('isActive') != is_active:
            logger.info(f"Subscription status changed for user {user_id}: isActive={is_active}")
            
            @firestore.transactional
            def update_user_in_transaction(transaction, user_ref):
                transaction.update(user_ref, {
                    'isPremium': is_active,
                    'premiumSince': firestore.SERVER_TIMESTAMP if is_active else None,
                    'premiumPlan': after_data.get('planType') if is_active else None,
                    'updatedAt': firestore.SERVER_TIMESTAMP
                })
            
            user_ref = db.collection('users').document(user_id)
            db.run_transaction(lambda t: update_user_in_transaction(t, user_ref))
            
            # Log subscription event for analytics
            db.collection('subscriptionEvents').add({
                'userId': user_id,
                'eventType': 'status_change',
                'newStatus': is_active,
                'oldStatus': before_data.get('isActive'),
                'planType': after_data.get('planType'),
                'platform': after_data.get('platform'),
                'timestamp': firestore.SERVER_TIMESTAMP,
                'metadata': {
                    'expiryDate': after_data.get('expiryDate'),
                    'purchaseDate': after_data.get('purchaseDate')
                }
            })
            
    except Exception as e:
        logger.error(f"Error handling subscription update: {str(e)}")

# Additional utility functions
@https_fn.on_request(
    memory=options.MemoryOption.MB_256,
    timeout_sec=60
)
def reset_user_usage(request):
    """Admin function to reset user usage (for testing or support)"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        admin_key = data.get('adminKey')
        
        if not user_id or not admin_key:
            return ({'success': False, 'error': 'Missing userId or adminKey'}, 400, headers)
        
        # Verify admin key from environment or Firebase config
        expected_admin_key = os.environ.get('ADMIN_KEY')
        if not expected_admin_key:
            expected_admin_key = os.environ.get('FIREBASE_CONFIG', {}).get('admin', {}).get('key')
            
        if not expected_admin_key or admin_key != expected_admin_key:
            return ({'success': False, 'error': 'Unauthorized'}, 401, headers)
        
        usage_ref = db.collection('usage').document(user_id)
        usage_ref.set({
            'apiCalls': 0,
            'batchScans': 0,
            'lastReset': datetime.now().isoformat(),
            'resetBy': 'admin',
            'resetAt': firestore.SERVER_TIMESTAMP
        }, merge=True)
        
        logger.info(f"Usage reset for user {user_id} by admin")
        return ({'success': True, 'message': 'Usage reset successfully'}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error resetting user usage: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def get_user_analytics(request):
    """Get analytics data for a user"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        user_id = data.get('userId')
        
        if not user_id:
            return ({'success': False, 'error': 'Missing userId'}, 400, headers)
        
        # Get user data
        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()
        
        if not user_doc.exists:
            return ({'success': False, 'error': 'User not found'}, 404, headers)
        
        user_data = user_doc.to_dict()
        
        # Get subscription data
        subscription_ref = db.collection('subscriptions').document(user_id)
        subscription_doc = subscription_ref.get()
        subscription_data = subscription_doc.to_dict() if subscription_doc.exists else {}
        
        # Get usage data
        usage_ref = db.collection('usage').document(user_id)
        usage_doc = usage_ref.get()
        usage_data = usage_doc.to_dict() if usage_doc.exists else {}
        
        # Get recent subscription events
        events_query = db.collection('subscriptionEvents').where('userId', '==', user_id).order_by('timestamp', direction=firestore.Query.DESCENDING).limit(10)
        events = [doc.to_dict() for doc in events_query.stream()]
        
        analytics = {
            'user': {
                'createdAt': user_data.get('createdAt'),
                'lastLogin': user_data.get('lastLogin'),
                'isPremium': user_data.get('isPremium', False),
                'stats': user_data.get('stats', {})
            },
            'subscription': {
                'isActive': subscription_data.get('isActive', False),
                'planType': subscription_data.get('planType'),
                'platform': subscription_data.get('platform'),
                'expiryDate': subscription_data.get('expiryDate'),
                'purchaseDate': subscription_data.get('purchaseDate')
            },
            'usage': {
                'apiCalls': usage_data.get('apiCalls', 0),
                'batchScans': usage_data.get('batchScans', 0),
                'lastReset': usage_data.get('lastReset')
            },
            'recentEvents': events
        }
        
        return ({'success': True, 'analytics': analytics}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error getting user analytics: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def batch_process_receipts(request):
    """Process multiple receipts in a batch for efficiency"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        data = request.get_json()
        if not data:
            return ({'success': False, 'error': 'No data provided'}, 400, headers)
            
        receipts = data.get('receipts', [])
        
        if not receipts or len(receipts) > 10:  # Limit batch size
            return ({'success': False, 'error': 'Invalid batch size (max 10)'}, 400, headers)
        
        results = []
        
        for receipt_data in receipts:
            user_id = receipt_data.get('userId')
            platform = receipt_data.get('platform')
            purchase_data = receipt_data.get('purchaseData')
            
            if not user_id or not platform or not purchase_data:
                results.append({
                    'userId': user_id,
                    'success': False,
                    'error': 'Missing required fields'
                })
                continue
            
            try:
                success = False
                
                if platform == 'ios':
                    success = process_ios_subscription(user_id, purchase_data)
                elif platform == 'android':
                    product_id = receipt_data.get('productId')
                    purchase_token = purchase_data.get('purchaseToken')
                    if product_id and purchase_token:
                        success = process_android_subscription(user_id, purchase_token, product_id)
                
                results.append({
                    'userId': user_id,
                    'success': success,
                    'error': None if success else 'Processing failed'
                })
                
            except Exception as e:
                results.append({
                    'userId': user_id,
                    'success': False,
                    'error': str(e)
                })
        
        return ({'success': True, 'results': results}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error in batch processing: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def cleanup_expired_subscriptions(request):
    """Cleanup expired subscriptions (should be called by Cloud Scheduler)"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        # Verify this is called by Cloud Scheduler or admin
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return ({'success': False, 'error': 'Unauthorized'}, 401, headers)
        
        # Query for expired active subscriptions
        now = datetime.now()
        subscriptions_query = db.collection('subscriptions').where('isActive', '==', True).where('expiryDate', '<', now)
        
        expired_count = 0
        batch = db.batch()
        
        for doc in subscriptions_query.stream():
            subscription_data = doc.to_dict()
            user_id = subscription_data.get('userId')
            
            # Update subscription status
            batch.update(doc.reference, {
                'isActive': False,
                'cancelledAt': firestore.SERVER_TIMESTAMP,
                'cancelledBy': 'system_cleanup'
            })
            
            # Update user premium status
            user_ref = db.collection('users').document(user_id)
            batch.update(user_ref, {
                'isPremium': False,
                'premiumPlan': None,
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            
            expired_count += 1
            
            # Commit in batches of 500 (Firestore limit)
            if expired_count % 500 == 0:
                batch.commit()
                batch = db.batch()
        
        # Commit remaining updates
        if expired_count % 500 != 0:
            batch.commit()
        
        logger.info(f"Cleaned up {expired_count} expired subscriptions")
        return ({'success': True, 'expiredCount': expired_count}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error cleaning up expired subscriptions: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

@https_fn.on_request()
def get_system_stats(request):
    """Get system statistics"""
    # Set CORS headers
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        db = get_firestore_client()
        
        # Count active subscriptions by plan
        subscriptions_query = db.collection('subscriptions').where('isActive', '==', True)
        active_subscriptions = list(subscriptions_query.stream())
        
        plan_counts = {'free': 0, 'monthly': 0, 'yearly': 0}
        platform_counts = {'ios': 0, 'android': 0}
        
        for sub in active_subscriptions:
            data = sub.to_dict()
            plan_type = data.get('planType', 'free')
            platform = data.get('platform', 'unknown')
            
            if plan_type in plan_counts:
                plan_counts[plan_type] += 1
            if platform in platform_counts:
                platform_counts[platform] += 1
        
        # Get total users
        users_query = db.collection('users')
        total_users = len(list(users_query.stream()))
        
        stats = {
            'totalUsers': total_users,
            'activeSubscriptions': len(active_subscriptions),
            'planBreakdown': plan_counts,
            'platformBreakdown': platform_counts,
            'timestamp': datetime.now().isoformat()
        }
        
        return ({'success': True, 'stats': stats}, 200, headers)
        
    except Exception as e:
        logger.error(f"Error getting system stats: {str(e)}")
        return ({'success': False, 'error': str(e)}, 500, headers)

# Error handler for unhandled exceptions
def handle_error(error):
    """Global error handler"""
    logger.error(f"Unhandled error: {str(error)}")
    return {'success': False, 'error': 'Internal server error'}, 500