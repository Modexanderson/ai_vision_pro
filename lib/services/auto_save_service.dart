// services/auto_save_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/detection_result.dart';
import '../models/detection_history.dart';

class AutoSaveService {
  static final AutoSaveService _instance = AutoSaveService._internal();
  factory AutoSaveService() => _instance;
  AutoSaveService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  bool _autoSaveEnabled = true;
  bool _isInitialized = false;

  // Storage paths
  static const String _imagesPath = 'detection_images';
  static const String _thumbnailsPath = 'detection_thumbnails';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _autoSaveEnabled = prefs.getBool('auto_save') ?? true;
      _isInitialized = true;
      debugPrint('Auto Save Service initialized');
    } catch (e) {
      debugPrint('Auto Save Service initialization failed: $e');
    }
  }

  bool get autoSaveEnabled => _autoSaveEnabled;

  Future<void> setAutoSaveEnabled(bool enabled) async {
    _autoSaveEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_save', enabled);
  }

  // Main auto-save method
  Future<DetectionHistory?> autoSaveDetectionResult(
      DetectionResult result) async {
    if (!_autoSaveEnabled) return null;

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Cannot auto-save: User not authenticated');
      return null;
    }

    try {
      debugPrint('Starting auto-save for detection: ${result.id}');

      // 1. Upload original image
      final imageUrl =
          await _uploadImage(result.imageFile, user.uid, result.id);

      // 2. Generate and upload thumbnail
      final thumbnailUrl = await _generateAndUploadThumbnail(
          result.imageFile, user.uid, result.id);

      // 3. Create detection history object
      final history = DetectionHistory(
        id: result.id,
        imagePath: result.imageFile.path, // Local path
        imageUrl: imageUrl, // Firebase Storage URL
        thumbnailUrl: thumbnailUrl, // Thumbnail URL
        detectedObjects: result.objects.map((obj) => obj.label).toList(),
        averageConfidence: result.averageConfidence,
        timestamp: result.timestamp,
        mode: result.mode,
        uploadStatus: 'completed',
        syncedToCloud: true,
      );

      // 4. Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('detection_history')
          .doc(result.id)
          .set(history.toMap());

      // 5. Update user's storage statistics
      await _updateUserStorageStats(user.uid, imageUrl, thumbnailUrl);

      debugPrint('✅ Auto-save completed for detection: ${result.id}');
      return history;
    } catch (e) {
      debugPrint('❌ Auto-save failed for detection ${result.id}: $e');

      // Save with failed upload status
      return await _saveWithFailedUpload(result, user.uid);
    }
  }

  // Upload original image to Firebase Storage
  Future<String> _uploadImage(
      File imageFile, String userId, String detectionId) async {
    try {
      final fileName =
          '${detectionId}_original${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('$_imagesPath/$userId/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'detectionId': detectionId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'userId': userId,
          },
        ),
      );

      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Image upload failed: $e');
      rethrow;
    }
  }

  // Generate and upload thumbnail
  Future<String> _generateAndUploadThumbnail(
      File imageFile, String userId, String detectionId) async {
    try {
      // Generate thumbnail (you'll need to add image processing dependency)
      final thumbnailFile = await _generateThumbnail(imageFile);

      final fileName =
          '${detectionId}_thumb${path.extension(thumbnailFile.path)}';
      final ref = _storage.ref().child('$_thumbnailsPath/$userId/$fileName');

      final uploadTask = ref.putFile(
        thumbnailFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'detectionId': detectionId,
            'type': 'thumbnail',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Clean up local thumbnail file
      await thumbnailFile.delete();

      debugPrint('✅ Thumbnail uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Thumbnail upload failed: $e');
      // Return empty string if thumbnail generation fails
      return '';
    }
  }

  // Generate thumbnail (simplified - you might want to use image processing library)
  Future<File> _generateThumbnail(File originalImage) async {
    // This is a placeholder - implement actual thumbnail generation
    // You can use packages like 'image' or 'flutter_image_compress'

    // For now, return a copy of the original (simplified)
    final thumbnailPath = originalImage.path.replaceAll('.jpg', '_thumb.jpg');
    return await originalImage.copy(thumbnailPath);
  }

  // Save with failed upload status
  Future<DetectionHistory> _saveWithFailedUpload(
      DetectionResult result, String userId) async {
    final history = DetectionHistory(
      id: result.id,
      imagePath: result.imageFile.path,
      imageUrl: '', // Empty - upload failed
      thumbnailUrl: '', // Empty - upload failed
      detectedObjects: result.objects.map((obj) => obj.label).toList(),
      averageConfidence: result.averageConfidence,
      timestamp: result.timestamp,
      mode: result.mode,
      uploadStatus: 'failed',
      syncedToCloud: false,
    );

    // Save to Firestore with failed status
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('detection_history')
        .doc(result.id)
        .set(history.toMap());

    return history;
  }

  // Update user's storage statistics
  Future<void> _updateUserStorageStats(
      String userId, String imageUrl, String thumbnailUrl) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'stats.totalImages': FieldValue.increment(1),
        'stats.lastUpload': FieldValue.serverTimestamp(),
        'storage.imagesCount': FieldValue.increment(1),
        'storage.lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to update user storage stats: $e');
    }
  }

  // Retry failed uploads
  Future<void> retryFailedUploads() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get failed uploads
      final failedUploads = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('detection_history')
          .where('uploadStatus', isEqualTo: 'failed')
          .limit(10) // Process 10 at a time
          .get();

      for (final doc in failedUploads.docs) {
        final history = DetectionHistory.fromMap(doc.data());
        final imageFile = File(history.imagePath);

        if (await imageFile.exists()) {
          try {
            // Retry upload
            final imageUrl =
                await _uploadImage(imageFile, user.uid, history.id);
            final thumbnailUrl = await _generateAndUploadThumbnail(
                imageFile, user.uid, history.id);

            // Update document
            await doc.reference.update({
              'imageUrl': imageUrl,
              'thumbnailUrl': thumbnailUrl,
              'uploadStatus': 'completed',
              'syncedToCloud': true,
              'retryCount': FieldValue.increment(1),
            });

            debugPrint('✅ Retry successful for: ${history.id}');
          } catch (e) {
            debugPrint('❌ Retry failed for ${history.id}: $e');

            // Update retry count
            await doc.reference.update({
              'retryCount': FieldValue.increment(1),
              'lastRetryAt': FieldValue.serverTimestamp(),
            });
          }
        } else {
          // Local file no longer exists, mark as permanently failed
          await doc.reference.update({
            'uploadStatus': 'permanently_failed',
            'failureReason': 'Local file not found',
          });
        }
      }
    } catch (e) {
      debugPrint('Error retrying failed uploads: $e');
    }
  }

  // Get upload statistics
  Future<Map<String, dynamic>> getUploadStatistics(String userId) async {
    try {
      final stats = await _firestore
          .collection('users')
          .doc(userId)
          .collection('detection_history')
          .get();

      int totalUploads = stats.docs.length;
      int successfulUploads = 0;
      int failedUploads = 0;
      int pendingUploads = 0;

      for (final doc in stats.docs) {
        final status = doc.data()['uploadStatus'] ?? 'unknown';
        switch (status) {
          case 'completed':
            successfulUploads++;
            break;
          case 'failed':
          case 'permanently_failed':
            failedUploads++;
            break;
          case 'pending':
            pendingUploads++;
            break;
        }
      }

      return {
        'totalUploads': totalUploads,
        'successfulUploads': successfulUploads,
        'failedUploads': failedUploads,
        'pendingUploads': pendingUploads,
        'successRate':
            totalUploads > 0 ? (successfulUploads / totalUploads) * 100 : 0,
      };
    } catch (e) {
      debugPrint('Error getting upload statistics: $e');
      return {};
    }
  }

  // Clean up old images (premium feature)
  Future<void> cleanupOldImages(String userId, {int keepDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

      final oldItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('detection_history')
          .where('timestamp', isLessThan: cutoffDate)
          .get();

      final batch = _firestore.batch();

      for (final doc in oldItems.docs) {
        final data = doc.data();
        final imageUrl = data['imageUrl'] as String?;
        final thumbnailUrl = data['thumbnailUrl'] as String?;

        // Delete from Storage
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(imageUrl).delete();
          } catch (e) {
            debugPrint('Failed to delete image: $e');
          }
        }

        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(thumbnailUrl).delete();
          } catch (e) {
            debugPrint('Failed to delete thumbnail: $e');
          }
        }

        // Delete document
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ Cleaned up ${oldItems.docs.length} old images');
    } catch (e) {
      debugPrint('❌ Cleanup failed: $e');
    }
  }

  // Get storage usage
  Future<double> getStorageUsage(String userId) async {
    try {
      // This would require Firebase Functions to calculate actual storage usage
      // For now, estimate based on number of images
      final stats = await getUploadStatistics(userId);
      final totalImages = stats['totalUploads'] as int? ?? 0;

      // Rough estimate: 2MB per image + 200KB per thumbnail
      final estimatedUsageMB = (totalImages * 2.2);

      return estimatedUsageMB;
    } catch (e) {
      debugPrint('Error calculating storage usage: $e');
      return 0.0;
    }
  }
}
