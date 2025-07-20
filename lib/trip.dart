import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picdrop/facegroup.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'gallerypage.dart';
import 'ai.dart';
import 'package:path_provider/path_provider.dart';

class Trip extends StatefulWidget {
  final String tripName;

  const Trip({super.key, required this.tripName});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  final ImagePicker picker = ImagePicker();
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    loadTripImages();
    loadFaceGroups();
  }

  Future<void> loadTripImages() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'trip_${widget.tripName}';
    final paths = prefs.getStringList(key) ?? [];

    final validFiles = <File>[];
    for (var path in paths) {
      final file = File(path);
      if (await file.exists()) {
        validFiles.add(file);
      }
    }

    setState(() {
      images = validFiles;
    });
  }

  Future<void> groupFaces(List<File> allTripImages) async {
    final faceProcessor = FaceProcessor(tripName: widget.tripName);
    await faceProcessor.processTripImages(allTripImages);
    print("Face grouping complete.");
    await loadFaceGroups(); // <- Add this to reload face groups
  }

  Future<void> addPhotos() async {
    final List<XFile> selectedImages = await picker.pickMultiImage();
    if (selectedImages.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'trip_${widget.tripName}';

    List<String> existingPaths = prefs.getStringList(key) ?? [];

    // Add new paths and avoid duplicates
    final newPaths = selectedImages.map((e) => e.path).toSet();
    existingPaths.addAll(newPaths);
    existingPaths = existingPaths.toSet().toList();

    await prefs.setStringList(key, existingPaths);

    loadTripImages(); // Refresh UI
  }

  Future<void> removeImage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'trip_${widget.tripName}';

    final updatedImages = List<File>.from(images)..removeAt(index);
    final updatedPaths = updatedImages.map((f) => f.path).toList();

    await prefs.setStringList(key, updatedPaths);
    setState(() {
      images = updatedImages;
    });
  }

  Future<void> shareTripImages() async {
    if (images.isEmpty) return;

    final existing = images.where((img) => img.existsSync()).toList();

    if (existing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid images to share.")),
      );
      return;
    }

    final xFiles = existing.map((img) => XFile(img.path)).toList();

    await Share.shareXFiles(
      xFiles,
      text: "Check out my trip photos from '${widget.tripName}'!",
    );
  }

  Map<String, List<String>> faceGroups = {};

  Future<void> loadFaceGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final appDocDir = await getApplicationDocumentsDirectory();

    final keys = prefs.getKeys().where(
      (k) => k.startsWith('face_${widget.tripName}_'),
    );

    final loaded = <String, List<String>>{};
    for (final key in keys) {
      final groupKey = key.replaceFirst('face_${widget.tripName}_', '');
      final paths = prefs.getStringList(key) ?? [];
      loaded[groupKey] = paths;
    }

    setState(() {
      faceGroups = loaded;
    });
  }

  Future<File> getThumbnailFile(
    String tripName,
    String faceId,
    List<String> faceImagePaths,
  ) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final thumbPath = '${baseDir.path}/faces/$tripName/$faceId/thumb.jpg';
    final thumbFile = File(thumbPath);

    if (await thumbFile.exists() && await thumbFile.length() > 0) {
      return thumbFile;
    }

    final fallback = File(faceImagePaths.first);
    if (await fallback.exists() && await fallback.length() > 0) {
      return fallback;
    }

    throw Exception("No valid thumbnail or fallback image found.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripName),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: shareTripImages),
          IconButton(
            icon: const Icon(Icons.face_retouching_natural),
            onPressed: () => groupFaces(images),
          ),
        ],
      ),

      body: Column(
        children: [
          if (faceGroups.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: faceGroups.length,
                itemBuilder: (context, index) {
                  final faceId = faceGroups.keys.elementAt(index);
                  final facePaths = faceGroups[faceId]!;

                  return FutureBuilder<File>(
                    future: getThumbnailFile(
                      widget.tripName,
                      faceId,
                      facePaths,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(),
                        );
                      }

                      final thumbFile = snapshot.data!;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FaceGroupPage(
                                faceGroups: {faceId: facePaths},
                                onDelete: (faceId, index) {
                                  setState(() {
                                    faceGroups[faceId]!.removeAt(index);
                                    if (faceGroups[faceId]!.isEmpty) {
                                      faceGroups.remove(faceId);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: FileImage(thumbFile),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          const Divider(),
          Expanded(
            child: images.isEmpty
                ? const Center(child: Text('No images in this trip.'))
                : GalleryPage(
                    title: widget.tripName,
                    imagePaths: images.map((f) => f.path).toList(),
                    onDelete: (index) => removeImage(index),
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addPhotos,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
