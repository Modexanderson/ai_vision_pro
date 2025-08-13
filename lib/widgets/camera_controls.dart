// widgets/camera_controls.dart

import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final bool isProcessing;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button (could be implemented to pick image)
          IconButton(
            icon:
                const Icon(Icons.photo_library, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          // Capture button
          GestureDetector(
            onTap: isProcessing ? null : onCapture,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: isProcessing ? Colors.grey : Colors.transparent,
              ),
              child: isProcessing
                  ? const Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.circle, color: Colors.white, size: 60),
                    ),
            ),
          ),

          // Switch camera button
          IconButton(
            icon: const Icon(Icons.flip_camera_ios,
                color: Colors.white, size: 28),
            onPressed: isProcessing ? null : onSwitchCamera,
          ),
        ],
      ),
    );
  }
}
