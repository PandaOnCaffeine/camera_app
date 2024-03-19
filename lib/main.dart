// ignore_for_file: unused_import

// Flutter Imports
import 'package:flutter/material.dart';

// My Repository
import '../Repository/image_repository.dart';
import '../Repository/api_image_repository.dart';
import '../Repository/local_image_repository.dart';

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
import 'Services/api_auth_service.dart';
import 'Services/notification_service.dart';

// Firebase Imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Things to make:
///
/// JWT Tokens - Done
/// Repository Pattern - Done
/// Integration Test - WIP
/// Isolate - WIP
/// Compute - Done
/// Foreground Notification - Done
/// BackGround Notification - Done

/// Services and Other
// ShellNavigatorKey for Routing
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// My Repositories / Change Repository Between LocalStorage and Api
// final ImageRepository _repository = LocalImageRepository(); // Ùse LocalStorage Repository
final ImageRepository _repository = ApiImageRepository(); // Use Api Repository

// ApiService for the screens that need the ApiService
final ApiAuthService _apiAuth = ApiAuthService();

// Notification service
final ForegroundNotifyService _notificationService =
    ForegroundNotifyService();

// List of cameras for the camera Screen.
late List<CameraDescription> _cameras;

/// Main method
/// Starts the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Starts a firebase instance
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notification Permissions Request
  _notificationService.requestNotificationPermissions();

  // Foreground Notification
  _notificationService.firebaseInit();

  // Background Notification
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  _cameras = await availableCameras();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("Fcm Token: $fcmToken");
  runApp(const MyApp());
}

// Background Notification entry point / Allows notification to open app
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  debugPrint("Handling in Background: ${message.messageId}");
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
            return HomeScreen(apiAuth: _apiAuth);
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'camera',
              builder: (BuildContext context, GoRouterState state) {
                return CameraApp(repository: _repository, cameras: _cameras);
              },
            ),
            GoRoute(
              path: 'viewPicture',
              builder: (BuildContext context, GoRouterState state) {
                return ViewPictureScreen(repository: _repository,);
              },
            ),
            GoRoute(
              path: 'dragNdrop',
              builder: (BuildContext context, GoRouterState state) {
                return DragNDropScreen(repository: _repository,);
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
