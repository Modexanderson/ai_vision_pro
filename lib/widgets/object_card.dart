// widgets/object_card.dart

import 'package:flutter/material.dart';
import 'package:ai_vision_pro/models/detected_object.dart';

class ObjectCard extends StatelessWidget {
  final DetectedObject object;
  final VoidCallback onTap;

  const ObjectCard({
    super.key,
    required this.object,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color confidence indicator
              Container(
                width: 8,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorForConfidence(object.confidence),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),

              // Object information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      object.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Confidence: ${(object.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (object.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        object.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow indicator
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForConfidence(double confidence) {
    if (confidence >= 0.7) {
      return Colors.green;
    } else if (confidence >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
