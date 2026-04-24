import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from either Camera or Gallery
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress to save bandwidth/storage
        maxWidth: 1080,   // Optimize resolution for AI
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      // You can log errors here if needed
      return null;
    }
  }
}