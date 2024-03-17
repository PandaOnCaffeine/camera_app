import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/API/api_service.dart';
import 'package:camera_app/main.dart';

// Define a mock class for CameraController
class MockCameraController extends Mock implements CameraController {}

// Mock ApiService
class MockApiService extends Mock implements ApiService {}

void main() {
  group('CameraApp Widget', () {
    late CameraController mockCameraController;
    late ApiService mockApiService;
    const mockCameraDescription = CameraDescription(
      name: 'mock_camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    setUp(() {
      mockCameraController = MockCameraController();
      mockApiService = MockApiService();
    });

    testWidgets('Test taking a picture', (WidgetTester tester) async {
      // Mock available cameras
      when(availableCameras()).thenAnswer((_) async => [mockCameraDescription]);

      // Mock initialization of CameraController
      when(mockCameraController.initialize()).thenAnswer((_) async {});

      // Mock taking a picture
      when(mockCameraController.takePicture())
          .thenAnswer((_) async => XFile('path/to/image'));

      // Build CameraApp widget with mocked dependencies
      await tester.pumpWidget(CameraApp(
          cameraController: mockCameraController, apiService: mockApiService));

      // Verify that CameraPreview is rendered
      expect(find.byType(CameraPreview), findsOneWidget);

      // Simulate pressing the take picture button
      await tester.tap(find.byType(FloatingActionButton).at(1));
      await tester.pump();

// Verify that the picture is taken and the ApiService.saveImage method is called
      verify(mockApiService
              .saveImage("asd"))
          .called(1);
    });
  });
}
