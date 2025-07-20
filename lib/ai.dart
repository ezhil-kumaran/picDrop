import 'dart:io';
import "dart:ui";
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceProcessor {
  final String tripName;
  final FaceDetector detector = FaceDetector(
    options: FaceDetectorOptions(enableContours: false, enableLandmarks: false),
  );
  FaceProcessor({required this.tripName});
  final Map<String, List<File>> faceGroups = {};
  final Map<String, String> imageToGroup = {}; // Map image to group ID

  Future<void> processTripImages(List<File> imageFiles) async {
    final appDocDir = await getApplicationDocumentsDirectory();

    for (final file in imageFiles) {
      final bytes = await file.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) continue;

      final inputImage = InputImage.fromFile(file);
      final List<Face> faces = await detector.processImage(inputImage);

      for (final face in faces) {
        final cropped = cropFace(originalImage, face.boundingBox);
        if (cropped == null) continue;

        final hash = _getAverageColorHash(cropped);
        final groupId = _findGroupForHash(hash) ?? const Uuid().v4();

        final groupDir = Directory(
          p.join(appDocDir.path, 'faces', tripName, groupId),
        );
        await groupDir.create(recursive: true);

        final fileName = 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final croppedPath = p.join(groupDir.path, fileName);

        final croppedBytes = img.encodeJpg(cropped);
        final croppedFile = File(croppedPath);
        await croppedFile.writeAsBytes(croppedBytes);

        faceGroups.putIfAbsent(groupId, () => []).add(croppedFile);

        faceGroups.putIfAbsent(groupId, () => []).add(croppedFile);
      }
    }

    await _saveFaceGroups();
  }

  img.Image? cropFace(img.Image source, Rect boundingBox) {
    try {
      final x = boundingBox.left.toInt().clamp(0, source.width - 1);
      final y = boundingBox.top.toInt().clamp(0, source.height - 1);
      final w = boundingBox.width.toInt().clamp(1, source.width - x);
      final h = boundingBox.height.toInt().clamp(1, source.height - y);
      return img.copyCrop(source, x: x, y: y, width: w, height: h);
    } catch (_) {
      return null;
    }
  }

  String _getAverageColorHash(img.Image faceImage) {
    num r = 0, g = 0, b = 0;
    int count = 0;

    for (int y = 0; y < faceImage.height; y++) {
      for (int x = 0; x < faceImage.width; x++) {
        final pixel = faceImage.getPixel(x, y); // Pixel object
        r += pixel.r;
        g += pixel.g;
        b += pixel.b;
        count++;
      }
    }

    if (count == 0) return '0-0-0';

    r = (r / count).round();
    g = (g / count).round();
    b = (b / count).round();

    return '$r-$g-$b';
  }

  String? _findGroupForHash(String hash) {
    int threshold = 40;
    final rgb = hash.split('-').map(int.parse).toList();
    for (final entry in faceGroups.entries) {
      final anyFace = entry.value.first;
      final bytes = anyFace.readAsBytesSync();
      final refImage = img.decodeImage(bytes);
      if (refImage == null) continue;

      final refHash = _getAverageColorHash(refImage);
      final refRgb = refHash.split('-').map(int.parse).toList();
      final diff = sqrt(
        pow(rgb[0] - refRgb[0], 2) +
            pow(rgb[1] - refRgb[1], 2) +
            pow(rgb[2] - refRgb[2], 2),
      );
      if (diff < threshold) return entry.key;
    }
    return null;
  }

  // Add at top if not present

  Future<void> _saveFaceGroups() async {
    final dir = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();

    // Clear old groups
    for (var key in prefs.getKeys()) {
      if (key.startsWith('face_${tripName}_')) {
        await prefs.remove(key);
      }
    }

    for (final entry in faceGroups.entries) {
      final groupId = entry.key;
      final paths = <String>[];

      for (final file in entry.value) {
        final imageName = p.basename(file.path);
        final newPath = p.join(dir.path, 'faces', tripName, groupId, imageName);
        await File(file.path).copy(newPath);
        paths.add(newPath);
      }

      // Save a thumbnail
      if (paths.isNotEmpty) {
        final firstFile = File(paths.first);
        if (await firstFile.exists() && await firstFile.length() > 0) {
          final thumbPath = p.join(
            dir.path,
            'faces',
            tripName,
            groupId,
            'thumb.jpg',
          );
          await firstFile.copy(thumbPath);
        }
      }

      await prefs.setStringList('face_${tripName}_$groupId', paths);
    }

    print("Saved ${faceGroups.length} face groups to SharedPreferences");
  }
}
