import 'package:localstorage/localstorage.dart';

// My Image Repository
import 'image_repository.dart';

class LocalImageRepository implements ImageRepository {
  final LocalStorage storage = LocalStorage('camera_app_images.json');
  @override
  Future<void> saveImage(String imageBase64) async {
    List<String> images = [];
    // Load from local Storage
    dynamic storedImages = storage.getItem('images');
    if (storedImages != null && storedImages is List<dynamic>) {
      images = storedImages.cast<String>();
    } else {
      // Handle case where the stored images are null or not of the expected type
    }

    // Add the image to the list
    images.add(imageBase64);

    // Save the images to localstorage
    await storage.ready;
    storage.setItem('images', images);
  }

  @override
  Future<List<String>> getImages() async {
    List<String> imageBase64List = [];

    // Load from local Storage
    await storage.ready;
    dynamic storedImages = storage.getItem('images');
    if (storedImages != null && storedImages is List<dynamic>) {
      imageBase64List = storedImages.cast<String>();
    } else {
      // Handle case where the stored images are null or not of the expected type
    }

    return imageBase64List;
  }
}
