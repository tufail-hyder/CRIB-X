import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/exceptions/app_exception.dart';

class CloudinaryService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get _preset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String> uploadImage(File file) async {
    if (_cloudName.isEmpty || _preset.isEmpty) {
      throw const AppException('Image upload is not configured.');
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': _preset,
    });

    final res = await _dio.post(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      data: form,
    );

    final url = res.data['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw const AppException('Image upload failed. Please try again.');
    }
    return url;
  }
}