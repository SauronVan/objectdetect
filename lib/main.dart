import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_object_detector/controller/speech_to_text_controller.dart';
import 'package:ai_object_detector/view/camera_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SpeechToTextController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detector App',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            _buildNavigationButton(
              context,
              title: 'Find Object',
              destination: const SpeechAndCameraPage(title: 'Find Object'),
            ),
            const SizedBox(height: 20),
            _buildNavigationButton(
              context,
              title: 'Go Shopping',
              destination: const SpeechAndCameraPage(title: 'Go Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, {required String title, required Widget destination}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        height: 100,
        width: 350,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 22.0),
          ),
        ),
      ),
    );
  }
}

class SpeechAndCameraPage extends StatelessWidget {
  final String title;
  const SpeechAndCameraPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechToTextController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 25.0),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            elevation: 0.0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: DropdownButton<String>(
                    value: controller.selectedLanguage,
                    onChanged: (newValue) {
                      controller.setSelectedLanguage(newValue!);
                    },
                    items: controller.availableLanguages
                        .map((locale) => DropdownMenuItem(
                      value: locale.localeId,
                      child: Text(locale.name),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  controller.recognizedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: controller.isCameraActive
                      ? const CameraView()
                      : const Center(
                    child: Text(
                      'Press the "Camera" button to activate the camera',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.toggleListening,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.isListening ? 'Stop Listening' : 'Start Listening',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: controller.toggleCamera,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.isCameraActive ? 'Close Camera' : 'Camera',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
