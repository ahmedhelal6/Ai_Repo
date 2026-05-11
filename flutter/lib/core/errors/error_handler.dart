import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorHandler {
  static Failure handle(dynamic error, {String fallback = 'Something went wrong'}) {
    if (error is Failure) {
      return error;
    }

    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] ??
            responseData['error'] ??
            responseData['title'];

        if (message != null && message.toString().trim().isNotEmpty) {
          return Failure(message.toString());
        }
      }

      if (responseData is String && responseData.trim().isNotEmpty) {
        return Failure(responseData.trim());
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Failure('Connection timeout. Please try again.');

        case DioExceptionType.connectionError:
          return Failure('No internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;

          if (statusCode == 400) return Failure('Bad request.');
          if (statusCode == 401) return Failure('Unauthorized. Please login again.');
          if (statusCode == 404) return Failure('Not found.');
          if (statusCode == 500) return Failure('Server error. Please try again later.');

          return Failure(fallback);

        case DioExceptionType.cancel:
          return Failure('Request was cancelled.');

        default:
          return Failure(fallback);
      }
    }

    return Failure(fallback);
  }
}