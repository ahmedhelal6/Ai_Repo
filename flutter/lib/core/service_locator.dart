import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/chat_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final AuthService authService = AuthService();

  static final ChatService chatService = ChatService(authService);
}