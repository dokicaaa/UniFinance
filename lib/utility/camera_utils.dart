import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraUtils {
  static Future<File?> takePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        print("Image picked: ${pickedFile.path}");
        return File(pickedFile.path);
      } else {
        print("No image picked.");
        return null;
      }
    } catch (e) {
      print("Error in CameraUtils.takePicture: $e");
      return null;
    }
  }
}
