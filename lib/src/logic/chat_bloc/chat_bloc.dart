import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_model.dart';
import '../../data/sources/gemini_service.dart';

// --- EVENTS ---
abstract class ChatEvent {}

class SendMessageRequested extends ChatEvent {
  final String message;
  SendMessageRequested(this.message);
}

// --- STATES ---
abstract class ChatState {}

class ChatInitial extends ChatState {}

// Loading state mein hum purane messages pass karenge taakay UI se messages gayab na hon
class ChatLoading extends ChatState {
  final List<ChatMessage> previousMessages;
  ChatLoading(this.previousMessages);
}

class ChatMessageReceived extends ChatState {
  final List<ChatMessage> messages;
  ChatMessageReceived(this.messages);
}

// Error state jo Retry logic ko handle karegi
class ChatError extends ChatState {
  final String errorMessage;
  final List<ChatMessage> previousMessages;
  final String lastAttemptedMessage; // Jis message par error aaya

  ChatError({
    required this.errorMessage,
    required this.previousMessages,
    required this.lastAttemptedMessage,
  });
}

// --- BLOC LOGIC ---
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiService geminiService;
  final List<ChatMessage> _allMessages = [];

  ChatBloc(this.geminiService) : super(ChatInitial()) {
    on<SendMessageRequested>((event, emit) async {
      final userMessageText = event.message.trim();

      // 1. Agar ye retry hai, toh pichla message dubara list mein add nahi karenge
      // lekin agar naya message hai toh add karenge
      bool isAlreadyInList = _allMessages.isNotEmpty && _allMessages.last.text == userMessageText && _allMessages.last.isUser;

      if (!isAlreadyInList) {
        _allMessages.add(ChatMessage(
          text: userMessageText,
          isUser: true,
          time: DateTime.now(),
        ));
      }

      // 2. UI ko update karein user message ke saath
      emit(ChatMessageReceived(List.from(_allMessages)));

      // 3. Typing indicator dikhayein (Purane messages ke saath)
      emit(ChatLoading(List.from(_allMessages)));

      try {
        // 4. Gemini se response lein
        final response = await geminiService.getChatResponse(userMessageText);

        // 5. AI message add karein
        _allMessages.add(ChatMessage(
          text: response,
          isUser: false,
          time: DateTime.now(),
        ));

        emit(ChatMessageReceived(List.from(_allMessages)));
      } catch (e) {
        // 6. ERROR HANDLING: Agar 503 ya koi bhi error aaye
        // Hum list mein "Error message" add nahi karenge, balki Error State emit karenge
        emit(ChatError(
          errorMessage: e.toString().contains('503')
              ? "AI Server is overloaded (503)."
              : "Connection lost. Please check your internet.",
          previousMessages: List.from(_allMessages),
          lastAttemptedMessage: userMessageText,
        ));
      }
    });
  }
}