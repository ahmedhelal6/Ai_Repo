import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/core/service_locator.dart';
import 'package:ai_fitness_coach/services/chat_service.dart';

class ChatController {
  final ChatService chatService = ServiceLocator.chatService;

  Future<String> sendMessage({
    required List<Map<String, String>> messages,
  }) async {
    return chatService.sendMessage(messages: messages);
  }

  String getErrorMessage(Object error) {
    if (error is Failure) {
      return error.message;
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isNotEmpty && message != 'null') {
      return message;
    }

    return 'Something went wrong';
  }
}