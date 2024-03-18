abstract class ImageRepository {
  Future<List<String>> getImages();
  Future<void> saveImage(String imageBase64);
}