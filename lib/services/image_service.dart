// services/image_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Take a picture using the camera
  Future<File?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
    return null;
  }

  // Pick an image from the gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  // Save camera captured image to app's documents directory
  Future<File?> saveImage(XFile imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage =
          await File(imageFile.path).copy('${appDir.path}/$fileName');
      return savedImage;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }
}
