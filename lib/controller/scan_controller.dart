import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:developer';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var detectedObject = Rxn<Map<String, dynamic>>();  // Add this to hold detected objects

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void onClose() {
    cameraController.dispose();  // Properly dispose of cameraController here
    Tflite.close();
    super.onClose();
  }

  // Initialize Camera and start image stream
  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.yuv420,  // Use YUV420 for better performance
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update(); // Update UI with new information
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      log("Permission denied");
    }
  }

  // Load TensorFlow Lite Model
  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  // Object Detection Logic
  objectDetector(CameraImage image) async {
    var detector = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((e) => e.bytes).toList(),
      model: "SSDMobileNet",
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90, // Adjust the rotation as needed
      threshold: 0.4, // Confidence threshold
    );

    if (detector != null && detector.isNotEmpty) {
      var detected = detector.first;
      if (detected['confidenceInClass'] * 100 > 45) {
        detectedObject.value = {
          'detectedClass': detected['detectedClass'],
          'confidenceInClass': detected['confidenceInClass'],
          'rect': detected['rect'],
        };
      } else {
        detectedObject.value = null; // No valid detection
      }
      update(); // Update the UI with the detection results
    }
  }
}
