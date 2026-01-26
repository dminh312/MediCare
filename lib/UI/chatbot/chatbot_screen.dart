import 'dart:ui';
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildAppBar(isDarkMode, surfaceColor, primaryColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              children: [
                _buildDateChip(isDarkMode),
                const SizedBox(height: 24),
                _buildBotMessage(
                  isDarkMode,
                  'Hello Sarah! I can help you with your medications or any health questions. How are you feeling today?',
                  '10:24 AM',
                ),
                const SizedBox(height: 24),
                _buildUserMessage(
                  isDarkMode,
                  'Is it safe to take Vitamin C with my current medications?',
                  '10:25 AM',
                ),
                const SizedBox(height: 24),
                _buildTypingIndicator(isDarkMode),
              ],
            ),
          ),
          _buildInputArea(isDarkMode, primaryColor),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode, Color surfaceColor, Color primaryColor) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
          decoration: BoxDecoration(
            color: (isDarkMode ? surfaceColor : Colors.white).withAlpha(204),
            border: Border(bottom: BorderSide(color: isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50, width: 1.0)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left), 
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.grey[500],
                iconSize: 28,
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBWE7Jm66Y2Z2IF6SQOIcDF7F0_vufqELj6rO5h1awRV9CAyoqmpC3iD3syquhXShizfY_MFvjUD8QO7oj3epciP5UZSVObnkI9ocU7BDlNni8Wkk4bajr-11zPG6vfUEncEfM_WzPLQFcIIN5HjyhASKVDa8lQyFdXv1k7uRPa5wviW6OH1lrDU0RsQyHVeSOS0UBvYcLhAIRv2fq0hpbGbkc0IUXOZwfKO-n3eS2bG2Cvn3HfZArAIrHUa9YCi2WHUH16B7SlK_E'),
                    backgroundColor: isDarkMode ? primaryColor.withAlpha(51) : const Color(0xFFffebee),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                        border: Border.all(color: isDarkMode ? surfaceColor : Colors.white, width: 2),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MediCare+ AI Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black, height: 1.2)),
                    Text('Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.green[400] : Colors.green[600])),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 36, height: 36,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: isDarkMode ? primaryColor.withAlpha(51) : Colors.red[50],
                  elevation: 0,
                  heroTag: null, // Add this if you have multiple FABs
                  child: Icon(Icons.call, color: primaryColor, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(bool isDarkMode) {
    return Center(
      child: Chip(
        label: const Text('TODAY'),
        labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[500], letterSpacing: 0.5),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildBotMessage(bool isDarkMode, String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         CircleAvatar(
            radius: 16,
            backgroundColor: isDarkMode ? const Color(0xffff5252).withAlpha(51) : const Color(0xFFffebee),
            child: const Icon(Icons.medical_services, color: Color(0xffff5252), size: 18),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16), 
                bottomLeft: Radius.circular(16), 
                bottomRight: Radius.circular(16)
              ),
              border: Border.all(color: isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(fontSize: 15, height: 1.5, color: isDarkMode ? Colors.grey[200] : Colors.grey[800])),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(bool isDarkMode, String text, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: const BoxDecoration(
              color: Color(0xffff5252),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), 
                bottomLeft: Radius.circular(16), 
                bottomRight: Radius.circular(16)
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(text, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white)),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(178))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(bool isDarkMode) {
     return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         CircleAvatar(
            radius: 16,
            backgroundColor: isDarkMode ? const Color(0xffff5252).withAlpha(51) : const Color(0xFFffebee),
            child: const Icon(Icons.medical_services, color: Color(0xffff5252), size: 18),
          ),
        const SizedBox(width: 8),
        Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
           decoration: BoxDecoration(
             color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
             borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
             border: Border.all(color: isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50, width: 1.0),
           ),
           child: const Text("Typing...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
         ),
      ],
    );
  }

  Widget _buildInputArea(bool isDarkMode, Color primaryColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
        border: Border(top: BorderSide(color: isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50, width: 1.0)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSuggestionChip(isDarkMode, primaryColor, 'Check medication interactions'),
                _buildSuggestionChip(isDarkMode, primaryColor, 'Log a symptom'),
                _buildSuggestionChip(isDarkMode, primaryColor, 'Ask about dosage'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[900]?.withAlpha(102) : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () { /* TODO: Send message */ },
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                mini: true,
                heroTag: null,
                child: const Icon(Icons.send, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(bool isDarkMode, Color primaryColor, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text),
        onPressed: () => _textController.text = text,
        backgroundColor: isDarkMode ? primaryColor.withAlpha(26) : primaryColor.withAlpha(13),
        labelStyle: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryColor.withAlpha(128)),
        ),
      ),
    );
  }
}
