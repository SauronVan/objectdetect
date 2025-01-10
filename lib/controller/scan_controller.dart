import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:developer';

class ScanController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var x, y, w, h = 0.0;
  var label = "";

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );
      await cameraController.initialize().then((value) {
          cameraController.startImageStream((image) {
            cameraCount++;
            if (cameraCount % 10 == 0) {
              cameraCount = 0;
              objectDetector(image);
            }
            update();
          });
      });
      isCameraInitialized(true);
      update();
    } else {
      log("Permission denied");
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(bytesList: image.planes.map((e){
      return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if (detector != null) {
      var ourDetectedObject = detector.first;
      if (ourDetectedObject['confidenceInClass'] * 100 > 45) {
        label = ourDetectedObject['detectedClass'].toString();
        h = ourDetectedObject['rect']['h'];
        w = ourDetectedObject['rect']['w'];
        x = ourDetectedObject['rect']['x'];
        y = ourDetectedObject['rect']['y'];
      }
      update();
    }
  }
}