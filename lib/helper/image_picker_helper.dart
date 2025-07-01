import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks image from camera and returns it as base64 string
  static Future<String?> pickImageFromCamera() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera, imageQuality: 60);
      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        return base64Encode(bytes);
      }
    } catch (e) {
      print("Camera image picking error: $e");
    }
    return null;
  }

  /// Picks image from gallery and returns it as base64 string
  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        return base64Encode(bytes);
      }
    } catch (e) {
      print("Gallery image picking error: $e");
    }
    return null;
  }

  /// Decodes base64 string to `Uint8List` so it can be used with `Image.memory()`
  static Uint8List decodeBase64Image(String base64String) {
    return base64Decode(base64String);
  }
}
