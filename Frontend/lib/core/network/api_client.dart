
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({required String baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  // Mengirim request GET dan menerima JSON.
  Future<Map<String, dynamic>> get(String path) async {
    final response = await _dio.get<Object?>(path);
    return _readResponse(response.data);
  }

  // Mengirim request POST beserta data JSON.
  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _dio.post<Object?>(
      path,
      data: body,
    );

    return _readResponse(response.data);
  }

  // Memastikan response API berbentuk JSON object.
  Map<String, dynamic> _readResponse(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    throw const FormatException(
      'Invalid response format from API.',
    );
  }
}
