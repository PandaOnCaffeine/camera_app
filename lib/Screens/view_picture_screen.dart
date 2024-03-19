// Dart Imports
import 'dart:typed_data';
import 'dart:convert';

// Flutter Imports
import 'package:flutter/material.dart';

// My Repository
import '../Repository/image_repository.dart';

class ViewPictureScreen extends StatefulWidget {
  const ViewPictureScreen({super.key, required this.repository});

  // Repository
  final ImageRepository repository;

  @override
  State<ViewPictureScreen> createState() => _ViewPictureScreenState();
}

class _ViewPictureScreenState extends State<ViewPictureScreen> {
  List<Uint8List> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    // Repository GetImages
    List<String> response = await widget.repository.getImages();

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
