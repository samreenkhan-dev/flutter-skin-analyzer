import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/contants/app_colors.dart';
import '../../data/models/chat_model.dart';
import '../../logic/chat_bloc/chat_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("LUMINAIRE AI",
                style: TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text("Online Consultant", style: TextStyle(color: AppColors.textSub, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/app_bg.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.4)),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    List<ChatMessage> messages = [];
                    bool isTyping = false;
                    String? errorMsg;
                    String? lastMsg;

                    // States Handling
                    if (state is ChatMessageReceived) {
                      messages = state.messages;
                    } else if (state is ChatLoading) {
                      messages = state.previousMessages;
                      isTyping = true;
                    } else if (state is ChatError) {
                      messages = state.previousMessages;
                      errorMsg = state.errorMessage;
                      lastMsg = state.lastAttemptedMessage;
                    }

                    // Auto scroll when new message arrives
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                      // Extra items for Typing or Error
                      itemCount: messages.length + (isTyping ? 1 : 0) + (errorMsg != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < messages.length) {
                          return _buildMessageBubble(messages[index]);
                        }
                        if (isTyping) return _buildTypingIndicator();
                        if (errorMsg != null) return _buildRetrySection(errorMsg!, lastMsg!);
                        return const SizedBox();
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? AppColors.textMain : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 22),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : AppColors.textMain, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textMain),
            ),
            const SizedBox(width: 10),
            Text("AI is analyzing...", style: TextStyle(color: Colors.grey[700], fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  // ✅ RETRY SECTION: Jab 503 error aaye
  Widget _buildRetrySection(String error, String lastMessage) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.read<ChatBloc>().add(SendMessageRequested(lastMessage));
          },
          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
          label: const Text("Retry Message", style: TextStyle(color: Colors.white, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textMain,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  hintText: "Ask something...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isNotEmpty) {
                context.read<ChatBloc>().add(SendMessageRequested(_controller.text.trim()));
                _controller.clear();
              }
            },
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.textMain,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}