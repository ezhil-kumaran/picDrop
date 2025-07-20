import 'dart:io';
import 'package:flutter/material.dart';
import 'gallerypage.dart'; // Import your existing GalleryPage

class FaceGroupPage extends StatelessWidget {
  final Map<String, List<String>> faceGroups;
  final void Function(String faceId, int index) onDelete;

  const FaceGroupPage({
    super.key,
    required this.faceGroups,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final faceIds = faceGroups.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Grouped Faces")),
      body: faceGroups.isEmpty
          ? const Center(child: Text("No face groups found."))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: faceIds.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final faceId = faceIds[index];
                final images = faceGroups[faceId]!;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GalleryPage(
                          title: 'Face $faceId',
                          imagePaths: images,
                          onDelete: (imgIndex) => onDelete(faceId, imgIndex),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.file(
                        File(images.first),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Face $faceId',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
