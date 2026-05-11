import 'dart:io';
import 'package:dio/dio.dart';

class UploadService {
  final Dio _dio = Dio();

  // Replace with your actual API endpoint (e.g. Cloudinary or your custom backend)
  final String _uploadUrl = "https://api.cloudinary.com/v1_1/demo/image/upload"; 

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
        "upload_preset": "docs_upload_example_preset", // Required for Cloudinary
      });

      Response response = await _dio.post(_uploadUrl, data: formData);

      if (response.statusCode == 200) {
        // Return the secure URL from the response
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    List<String> urls = [];
    for (var file in imageFiles) {
      String? url = await uploadImage(file);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}
