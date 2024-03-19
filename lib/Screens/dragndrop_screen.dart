// Dart Imports
import 'dart:typed_data';
import 'dart:convert';

// Flutter Imports
import 'package:flutter/material.dart';

// My Repository
import '../Repository/image_repository.dart';

// Drag And Drop Screen
class DragNDropScreen extends StatefulWidget {
  const DragNDropScreen({super.key, required this.repository});

  // Repository
  final ImageRepository repository;

  @override
  State<DragNDropScreen> createState() => _DragNDropScreenScreenState();
}

class DroppedItem {
  final Widget widget;
  final Offset position;
  final Uint8List imageData;

  DroppedItem(
      {required this.widget, required this.position, required this.imageData});
}

class _DragNDropScreenScreenState extends State<DragNDropScreen> {
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    var base64ImagesFromStorage = await widget.repository.getImages();
    // ignore: unnecessary_null_comparison
    images = base64ImagesFromStorage != null
        ? List<String>.from(base64ImagesFromStorage)
        : [];
    setState(() {});
  }

  List<DroppedItem> droppedItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              decoration: BoxDecoration(
                image: droppedItems.isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(droppedItems.last.imageData),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                Uint8List imageData = base64Decode(images[index]);

                Widget imageWidget = SizedBox(
                  width: 100,
                  child: Image.memory(
                    imageData,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                );
                return LongPressDraggable<Widget>(
                  data: imageWidget,
                  feedback: imageWidget,
                  child: imageWidget,
                  onDragEnd: (details) {
                    setState(() {
                      droppedItems.add(DroppedItem(
                        widget: imageWidget,
                        position: details.offset,
                        imageData: imageData,
                      ));
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
