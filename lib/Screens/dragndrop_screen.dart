import 'dart:typed_data'; // Enable additional file types
import 'dart:convert'; // Convert to Base64
// Read file data

import 'package:flutter/material.dart';

// Pub.Dev Packages
import 'package:localstorage/localstorage.dart'; // Persist data

// My Services
import '../API/api_service.dart';

class DragNDropScreen extends StatefulWidget {
  const DragNDropScreen({super.key});

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
  final ApiService apiService = ApiService();
  final LocalStorage storage = LocalStorage('camera_app_images.json');
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    var base64ImagesFromStorage = await apiService.getImages();
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
          // Container(
          //   height: MediaQuery.of(context).size.height * 0.6,
          //   decoration: BoxDecoration(
          //     image: droppedItems.isNotEmpty
          //         ? DecorationImage(
          //             image: MemoryImage(droppedItems.last.imageData),
          //             fit: BoxFit.cover,
          //           )
          //         : null,
          //   ),
          // ),
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
                    height: MediaQuery.of(context).size.height * 0.2,
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
          // Container(
          //   // clipBehavior: Clip.antiAlias,
          //   height: MediaQuery.of(context).size.height * 0.2,
          //   color: const Color.fromARGB(255, 0, 0, 0),
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: images.length,
          //     itemBuilder: (context, index) {
          //       Uint8List imageData = base64Decode(images[index]);

          //       Widget imageWidget = SizedBox(
          //         width: 100,
          //         child: Image.memory(
          //           imageData,
          //           height: MediaQuery.of(context).size.height * 0.2,
          //         ),
          //       );
          //       return LongPressDraggable<Widget>(
          //         data: imageWidget,
          //         feedback: imageWidget,
          //         child: imageWidget,
          //         onDragEnd: (details) {
          //           setState(() {
          //             droppedItems.add(DroppedItem(
          //               widget: imageWidget,
          //               position: details.offset,
          //               imageData: imageData,
          //             ));
          //           });
          //         },
          //       );
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}
