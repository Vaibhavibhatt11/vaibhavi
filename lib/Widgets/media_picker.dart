// import 'package:image_picker/image_picker.dart';
//
// Future<XFile?> pickImageFromGallery() async {
//   final ImagePicker _picker = ImagePicker();
//   return await _picker.pickImage(source: ImageSource.gallery);
// }
//
// Future<XFile?> pickImageFromCamera() async {
//   final ImagePicker _picker = ImagePicker();
//   return await _picker.pickImage(source: ImageSource.camera);
// }


import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the device gallery.
  static Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Captures an image using the device camera.
  static Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      print('Error capturing image from camera: $e');
      return null;
    }
  }
}
