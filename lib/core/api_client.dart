import 'package:dio/dio.dart';

import 'config.dart';
import 'token_storage.dart';

/// Thin wrapper around Dio that injects the bearer token and normalises errors.
class ApiClient {
  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Auto clear token on 401 so the app returns to login.
          if (e.response?.statusCode == 401) {
            await _storage.clear();
          }
          handler.next(e);
        },
      ),
    );
  }

  final TokenStorage _storage;
  late final Dio dio;
}

/// A user-friendly error extracted from a Dio failure.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  factory ApiException.from(Object error) {
    if (error is DioException) {
      final res = error.response;
      if (res != null) {
        final data = res.data;
        if (data is Map<String, dynamic>) {
          final message = data['message']?.toString() ?? 'Terjadi kesalahan.';
          Map<String, List<String>>? fields;
          if (data['errors'] is Map) {
            fields = (data['errors'] as Map).map(
              (k, v) => MapEntry(
                k.toString(),
                (v as List).map((e) => e.toString()).toList(),
              ),
            );
          }
          return ApiException(message,
              statusCode: res.statusCode, fieldErrors: fields);
        }
        return ApiException('Kesalahan server (${res.statusCode}).',
            statusCode: res.statusCode);
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return ApiException(
            'Tidak dapat terhubung ke server. Periksa koneksi & alamat API.');
      }
    }
    return ApiException('Terjadi kesalahan tak terduga.');
  }

  @override
  String toString() => message;
}
