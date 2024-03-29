// Dart Imports
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

// Flutter Imports
import 'package:flutter/material.dart';

// Pub.Dev Packages
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

// My Services
// import '../Services/api_service.dart'; // For Api Service

// My Repository
import '../Repository/image_repository.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({super.key, required this.repository, required this.cameras});

  // Repository
  final ImageRepository repository;

  // Api Service
  // final ApiService apiService;

  final List<CameraDescription> cameras;
  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  /// Scaffold Key for snackBar further down in the class
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late CameraController controller;

  Uint8List imageData = Uint8List(0);
  String imageBase64 = "";

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle CameraAccessDenied errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(
              controller,
              child: Padding(
                padding: const EdgeInsets.only(bottom:25),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: "BackButton",
                      child: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 50),
                    FloatingActionButton(
                      heroTag: "TakePictureButton",
                      shape: const CircleBorder(),
                      onPressed: () async {
                        XFile file = await controller.takePicture();
                        debugPrint('Picture saved at ${file.path}');

                        // Read the file
                        imageData = await File(file.path).readAsBytes();
                        debugPrint('ImageData : $imageData');

                        // Encode image data to base64
                        imageBase64 = base64Encode(imageData);
                        debugPrint(
                            'Base64 Encoded: Length: ${imageBase64.length} : $imageBase64');

                        /// Repository SaveImage
                        await widget.repository.saveImage(imageBase64);

                        // Show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Picture taken'),
                          ),
                        );

                        // Update the UI
                        setState(() {});
                      },
                      child: (const Icon(Icons.camera_alt)),
                    ),
                    const SizedBox(width: 50),
                    FloatingActionButton(
                      heroTag: "GalleryButton",
                      child: const Icon(Icons.image_search),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/viewPicture');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
