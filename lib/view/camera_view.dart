import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_object_detector/controller/scan_controller.dart';
import 'package:camera/camera.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        // Dispose the camera controller when the widget is removed or camera is off
        dispose: (controller) {
          controller.dispose(); // Dispose the controller when the widget is removed
        },
        builder: (controller) {
          return controller.isCameraInitialized.value
              ? Stack(
            children: [
              // Mirror and rotate the camera preview
              Transform.scale(
                scaleX: -1,
                child: Transform.rotate(
                  angle: 90 * 3.1416 / 180,
                  child: Container(
                    width: 800,
                    height: 500,
                    child: CameraPreview(controller.cameraController),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(() {
                    final detected = controller.detectedObject.value;
                    if (detected != null) {
                      final rect = detected['rect'];

                      // Calculate bounding box position relative to parent widget
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      return Positioned(
                        top: rect['y'] * height,
                        left: rect['x'] * width,
                        child: Container(
                          width: rect['w'] * width,
                          height: rect['h'] * height,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              "${detected['detectedClass']} (${(detected['confidenceInClass'] * 100).toStringAsFixed(1)}%)",
                              style: const TextStyle(
                                color: Colors.white,
                                backgroundColor: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  });
                },
              ),
            ],
          )
              : const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
