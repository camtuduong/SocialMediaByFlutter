import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("No file selected");
    return null;
  }

  try {
    // Lấy file từ file picker
    File file = File(filePickerResult.files.single.path!);

    // Kiểm tra biến môi trường
    String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    if (cloudName.isEmpty) {
      throw Exception("Cloudinary Cloud Name is not defined in .env file");
    }

    // Tạo request
    var uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
    var request = http.MultipartRequest("POST", uri);

    // Đọc nội dung file
    var fileBytes = await file.readAsBytes();

    // Thêm file và metadata vào request
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: file.path.split("/").last,
    );
    request.files.add(multipartFile);

    // Các trường dữ liệu cần gửi
    request.fields['upload_preset'] = "preset-for-file-upload";
    request.fields['resource_type'] = "raw";

    // Gửi request
    var response = await request.send();

    // Phân tích phản hồi
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var responseJson = jsonDecode(responseBody);

      // Lấy URL của file tải lên
      String uploadedUrl = responseJson['secure_url'];
      print("Upload successful: $uploadedUrl");
      return uploadedUrl;
    } else {
      print("Upload failed with status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error uploading file: $e");
    return null;
  }
}
