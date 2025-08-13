// // widgets/safe_camera_preview.dart - Safe Camera Preview Component

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class SafeCameraPreview extends StatelessWidget {
//   final CameraController? controller;
//   final Widget? child;

//   const SafeCameraPreview({
//     super.key,
//     required this.controller,
//     this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Multiple safety checks to prevent disposed controller errors
//     if (controller == null) {
//       return _buildPlaceholder('Camera not available');
//     }

//     if (!controller!.value.isInitialized) {
//       return _buildPlaceholder('Initializing camera...');
//     }

//     // Additional check to ensure controller is not disposed
//     try {
//       final previewSize = controller!.value.previewSize;
//       if (previewSize == null) {
//         return _buildPlaceholder('Camera preview not ready');
//       }

//       return SizedBox(
//         width: double.infinity,
//         height: double.infinity,
//         child: FittedBox(
//           fit: BoxFit.cover,
//           child: SizedBox(
//             width: previewSize.height,
//             height: previewSize.width,
//             child: Stack(
//               children: [
//                 CameraPreview(controller!),
//                 if (child != null) child!,
//               ],
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       debugPrint('Error building camera preview: $e');
//       return _buildPlaceholder('Camera error occurred');
//     }
//   }

//   Widget _buildPlaceholder(String message) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.camera_alt_outlined,
//               size: 64,
//               color: Colors.white.withOpacity(0.5),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 16,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
