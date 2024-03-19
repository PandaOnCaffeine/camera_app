// Flutter Imports
import 'package:flutter/material.dart';

// Pub.Dev Packages
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

// My Widgets
import 'Widgets/burger_widget.dart';

// My Screens
import 'Screens/home_screen.dart';
import 'Screens/view_picture_screen.dart';
import 'Screens/dragndrop_screen.dart';
import 'Screens/camera_screen.dart';

// My Services
import 'Services/api_service.dart';
import 'Services/notification_service.dart';

// Firebase Imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Things to make:
///
/// JWT Tokens - Done
/// Repository Pattern - WIP
/// Integration Test - WIP
/// Isolate - WIP
/// Compute - Done

/// Services and other properties
// ShellNavigatorKey for Routing
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ApiService for the screens that need the ApiService
final ApiService _apiService = ApiService();

// List of cameras for the camera Screen.
late List<CameraDescription> _cameras;

/// Main method
/// Starts the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  requestNotificationPermissions();
  _cameras = await availableCameras();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("Fcm Token: $fcmToken");
  runApp(const MyApp());
}

/// Go Router
/// My go router with Routes to the different screens
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
            return HomeScreen(apiService: _apiService);
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'camera',
              builder: (BuildContext context, GoRouterState state) {
                return CameraApp(apiService: _apiService, cameras: _cameras);
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

/// MyApp Class
/// The class my main method starts
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

/// Root Screen
/// The Screen that My app starts on with appBar And BurgerMenu
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
