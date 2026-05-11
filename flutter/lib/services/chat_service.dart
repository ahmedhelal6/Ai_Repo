import 'dart:convert';

import 'package:ai_fitness_coach/core/errors/error_handler.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';

class ChatService {
  ChatService(this.authService);

  final AuthService authService;

  Future<String> sendMessage({
    required List<Map<String, String>> messages,
  }) async {
    try {
      if (messages.isEmpty) {
        throw Failure('Message is required');
      }

      final response = await authService.dio.post<dynamic>(
        '/api/Chat',
        data: {
          'messages': messages,
        },
      );

      return _extractReply(response.data);
    } catch (error) {
      throw ErrorHandler.handle(
        error,
        fallback: 'Failed to send chat message',
      );
    }
  }

  String _extractReply(dynamic data) {
    final decoded = _decodeIfString(data);

    if (decoded is Map<String, dynamic>) {
      final keys = [
        'reply',
        'message',
        'content',
        'response',
        'answer',
        'result',
        'data',
      ];

      for (final key in keys) {
        final value = decoded[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }

    throw Failure('Chat response does not contain a reply');
  }

  dynamic _decodeIfString(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }

    return data;
  }
}