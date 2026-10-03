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

    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': _preset,
      });

      final res = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: form,
      );

      final body = res.data;
      final url = body is Map ? body['secure_url']?.toString() : null;

      if (url == null || url.isEmpty) {
        throw const AppException('Image upload failed. Please try again.');
      }
      return url;
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;

      if (data is Map) {
        final error = data['error'];
        if (error is Map) {
          message = error['message']?.toString();
        }
      }

      if (message != null && message.isNotEmpty) {
        throw AppException('Upload failed: $message');
      }
      rethrow;
    }
  }
}