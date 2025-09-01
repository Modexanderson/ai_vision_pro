// services/ml_service.dart

import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ai_vision_pro/models/detected_object.dart' as app_models;

class MLService {
  final _objectDetector = GoogleMlKit.vision.objectDetector(
    options: ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    ),
  );

  final _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final _barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  final Uuid _uuid = const Uuid();

  Future<List<app_models.DetectedObject>> detectObjects(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<app_models.DetectedObject> results = [];

    try {
      final objects = await _objectDetector.processImage(inputImage);

      // Get image size for accurate bounding box conversion
      final decodedImage =
          await decodeImageFromList(imageFile.readAsBytesSync());
      final imageWidth = decodedImage.width.toDouble();
      final imageHeight = decodedImage.height.toDouble();

      // Convert ML Kit objects to our model
      for (final object in objects) {
        final boundingBox =
            _convertBoundingBox(object.boundingBox, imageWidth, imageHeight);

        // Get the label with highest confidence
        String label = 'Unknown';
        double highestConfidence = 0;

        for (final classification in object.labels) {
          if (classification.confidence > highestConfidence) {
            highestConfidence = classification.confidence;
            label = classification.text;
          }
        }

        results.add(
          app_models.DetectedObject(
            id: _uuid.v4(),
            label: label,
            confidence: highestConfidence,
            boundingBox: boundingBox,
          ),
        );
      }

      return results;
    } catch (e) {
      debugPrint('Object detection error: $e');
      rethrow;
    }
  }

  Future<List<app_models.DetectedObject>> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<app_models.DetectedObject> results = [];

    try {
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          if (line.text.trim().isNotEmpty) {
            results.add(
              app_models.DetectedObject(
                id: _uuid.v4(),
                label: line.text.trim(),
                confidence: 0.9, // Text recognition is generally reliable
                boundingBox: line.boundingBox,
                type: 'text',
              ),
            );
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Text extraction error: $e');
      rethrow;
    }
  }

  Future<List<app_models.DetectedObject>> scanBarcodes(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<app_models.DetectedObject> results = [];

    try {
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      for (Barcode barcode in barcodes) {
        String label = 'Barcode';
        String? displayValue = barcode.displayValue;

        // Determine barcode type
        switch (barcode.format) {
          case BarcodeFormat.qrCode:
            label = 'QR Code';
            break;
          case BarcodeFormat.ean13:
            label = 'EAN-13';
            break;
          case BarcodeFormat.ean8:
            label = 'EAN-8';
            break;
          case BarcodeFormat.upca:
            label = 'UPC-A';
            break;
          case BarcodeFormat.upce:
            label = 'UPC-E';
            break;
          case BarcodeFormat.code128:
            label = 'Code 128';
            break;
          case BarcodeFormat.code39:
            label = 'Code 39';
            break;
          default:
            label = 'Barcode';
        }

        results.add(
          app_models.DetectedObject(
            id: _uuid.v4(),
            label: displayValue ?? label,
            confidence:
                1.0, // Barcode detection is binary - it either works or doesn't
            boundingBox: barcode.boundingBox,
            type: 'barcode',
            rawValue: barcode.rawValue,
          ),
        );
      }

      return results;
    } catch (e) {
      debugPrint('Barcode scanning error: $e');
      rethrow;
    }
  }

  Rect _convertBoundingBox(
      Rect mlkitBox, double imageWidth, double imageHeight) {
    // Convert ML Kit coordinates to normalized coordinates for Flutter
    return Rect.fromLTWH(
      mlkitBox.left,
      mlkitBox.top,
      mlkitBox.width,
      mlkitBox.height,
    );
  }

  void dispose() {
    _objectDetector.close();
    _textRecognizer.close();
    _barcodeScanner.close();
  }
}
