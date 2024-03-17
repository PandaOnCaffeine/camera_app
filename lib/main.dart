import 'dart:typed_data'; // Enable additional file types
import 'dart:convert'; // Convert to Base64
import 'dart:io'; // Read file data

import 'package:flutter/material.dart';

// Pub.Dev Packages
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:localstorage/localstorage.dart';

// My Widgets
import 'Widgets/burger_widget.dart';

// My Screens
import 'Screens/home_screen.dart';
import 'Screens/view_picture_screen.dart';
import 'Screens/dragndrop_screen.dart';

// My Services
import 'API/api_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) =>
          NoTransitionPage(child: RootScreen(child: child)),
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'camera',
              builder: (BuildContext context, GoRouterState state) {
                return const CameraApp();
              },
            ),
            GoRoute(
              path: 'viewPicture',
              builder: (BuildContext context, GoRouterState state) {
                return const ViewPictureScreen();
              },
            ),
            GoRoute(
              path: 'dragNdrop',
              builder: (BuildContext context, GoRouterState state) {
                return const DragNDropScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

//Root Screen
class RootScreen extends StatelessWidget {
  final Widget child;

  const RootScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      appBar: AppBar(
        title: const Text('Navigator Thingy'),
      ),
      drawer: const BurgerMenuWidget(),
    );
  }
}

late List<CameraDescription> _cameras;

class CameraApp extends StatefulWidget {
  const CameraApp({super.key, cameraController, apiService});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final ApiService apiService = ApiService();
  
  final LocalStorage storage = LocalStorage('camera_app_images.json');

  late CameraController controller;

  Uint8List imageData = Uint8List(0);
  String imageBase64 = "";
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    var imagesFromStorage = storage.getItem('images');
    images =
        imagesFromStorage != null ? List<String>.from(imagesFromStorage) : [];
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
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
          CameraPreview(
            controller,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
                      print('Picture saved at ${file.path}');

                      // Read the file
                      imageData = await File(file.path).readAsBytes();
                      print('ImageData : $imageData');

                      // Encode image data to base64
                      imageBase64 = base64Encode(imageData);
                      print('Base64 Encoded: Length: ${imageBase64.length} : $imageBase64');

                      /// Api
                      await apiService.saveImage(imageBase64);

                      
                      /*/// Localstorage
                      // List<String> images = [];
                      // dynamic storedImages = storage.getItem('images');
                      // if (storedImages != null &&
                      //     storedImages is List<dynamic>) {
                      //   images = storedImages.cast<String>();
                      // } else {
                      //   // Handle the case where the stored images are null or not of the expected type
                      // }

                      // // Add the new image to the list
                      // images.add(imageString);

                      // // Save the list back to localstorage
                      // await storage.ready;
                      // storage.setItem('images', images);
                      ///
                      */

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
        ],
      ),
    );
  }
}
