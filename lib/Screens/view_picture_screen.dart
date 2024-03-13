import 'dart:typed_data'; // Enable additional file types
import 'dart:convert'; // Convert to Base64
import 'dart:io'; // Read file data

import 'package:flutter/material.dart';

// Pub.Dev Packages
import 'package:localstorage/localstorage.dart'; // Persist data

// My Services
import '../API/api_service.dart';

class ViewPictureScreen extends StatefulWidget {
  const ViewPictureScreen({super.key});
  @override
  State<ViewPictureScreen> createState() => _ViewPictureScreenState();
}

class _ViewPictureScreenState extends State<ViewPictureScreen> {
  final ApiService apiService = ApiService();
  final LocalStorage storage = LocalStorage('camera_app_images.json');
  List<Uint8List> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    /* LocalStorage
    // Wait for localstorage to be ready for read/write operations
    await storage.ready;

    // return the images item from storage
    dynamic base64ImagesFromStorage = storage.getItem('images');


    // change from dynamic to List of strings
    List<String> base64Images = base64ImagesFromStorage != null
        ? List<String>.from(base64ImagesFromStorage)
        : [];
    // decode from base64 LOCALSTORAGE
    images =
        base64Images.map((base64Image) => base64Decode(base64Image)).toList();
    */

    // API call
    List<String> response = await apiService.getImages();

    // decode from base64 API
    images = response.map((response) => base64Decode(response)).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // number of items per row
          mainAxisSpacing: 20,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenImageScreen(image: images[index]),
                ),
              );
            },
            child: Image.memory(images[index]),
          );
        },
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final Uint8List image;

  const FullScreenImageScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Center(
        child: Image.memory(image),
      ),
    );
  }
}
