// models/detected_object.dart - FIXED VERSION

import 'dart:ui';

class DetectedObject {
  final String id;
  final String label;
  final double confidence;
  final Rect boundingBox;
  final String? description;
  final String? funFact;
  final double? estimatedPrice;
  final String? type;
  final String? rawValue;

  DetectedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.description,
    this.funFact,
    this.estimatedPrice,
    this.type,
    this.rawValue,
  });

  DetectedObject copyWith({
    String? id,
    String? label,
    double? confidence,
    Rect? boundingBox,
    String? description,
    String? funFact,
    double? estimatedPrice,
    String? type,
    String? rawValue,
  }) {
    return DetectedObject(
      id: id ?? this.id,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      boundingBox: boundingBox ?? this.boundingBox,
      description: description ?? this.description,
      funFact: funFact ?? this.funFact,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      type: type ?? this.type,
      rawValue: rawValue ?? this.rawValue,
    );
  }

  // JSON serialization (for general use)
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'confidence': confidence,
        'boundingBox': {
          'left': boundingBox.left,
          'top': boundingBox.top,
          'right': boundingBox.right,
          'bottom': boundingBox.bottom,
        },
        'description': description,
        'funFact': funFact,
        'estimatedPrice': estimatedPrice,
        'type': type,
        'rawValue': rawValue,
      };

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    final boundingBoxData = json['boundingBox'];
    return DetectedObject(
      id: json['id'],
      label: json['label'],
      confidence: json['confidence'].toDouble(),
      boundingBox: Rect.fromLTRB(
        boundingBoxData['left'].toDouble(),
        boundingBoxData['top'].toDouble(),
        boundingBoxData['right'].toDouble(),
        boundingBoxData['bottom'].toDouble(),
      ),
      description: json['description'],
      funFact: json['funFact'],
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      type: json['type'],
      rawValue: json['rawValue'],
    );
  }

  // Firestore serialization (using LTWH format for bounding box)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'confidence': confidence,
      'boundingBox': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'width': boundingBox.width,
        'height': boundingBox.height,
      },
      'type': type,
      'description': description,
      'funFact': funFact,
      'estimatedPrice': estimatedPrice,
      'rawValue': rawValue,
    };
  }

  // Static factory method for Firestore deserialization
  static DetectedObject fromMap(Map<String, dynamic> map) {
    final boundingBoxData = map['boundingBox'] as Map<String, dynamic>;

    return DetectedObject(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      boundingBox: Rect.fromLTWH(
        boundingBoxData['left']?.toDouble() ?? 0.0,
        boundingBoxData['top']?.toDouble() ?? 0.0,
        boundingBoxData['width']?.toDouble() ?? 0.0,
        boundingBoxData['height']?.toDouble() ?? 0.0,
      ),
      type: map['type'],
      description: map['description'],
      funFact: map['funFact'],
      estimatedPrice: map['estimatedPrice']?.toDouble(),
      rawValue: map['rawValue'],
    );
  }

  @override
  String toString() {
    return 'DetectedObject(id: $id, label: $label, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectedObject &&
        other.id == id &&
        other.label == label &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return Object.hash(id, label, confidence);
  }
}
