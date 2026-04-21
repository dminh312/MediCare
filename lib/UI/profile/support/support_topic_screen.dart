import 'package:flutter/material.dart';
import 'package:medicare/UI/profile/support/live_chat_screen.dart';

class SupportTopicScreen extends StatefulWidget {
  const SupportTopicScreen({super.key});

  @override
  State<SupportTopicScreen> createState() => _SupportTopicScreenState();
}

class _SupportTopicScreenState extends State<SupportTopicScreen> {
  final TextEditingController _topicController = TextEditingController();
  final List<String> _popularTopics = [
    'Medication Help',
    'Appointment Sync',
    'Health Records',
    'Technical Issue'
  ];

  String _selectedTopic = '';

  void _startChat() {
    String finalTopic = _topicController.text.trim();
    if (finalTopic.isEmpty && _selectedTopic.isNotEmpty) {
      finalTopic = _selectedTopic;
    }
    
    if (finalTopic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select a topic to continue.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LiveChatScreen(topic: finalTopic),
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final bgColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffffbfb);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final onSurfaceColor = isDarkMode ? Colors.white : const Color(0xff1a1111);
    final onSurfaceVariantColor = isDarkMode ? Colors.white70 : const Color(0xff534343);
    final borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: onSurfaceColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'How can we help today?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our clinical support team is standing by to assist with your health journey.',
                style: TextStyle(
                  fontSize: 16,
                  color: onSurfaceVariantColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // Custom text input
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _topicController,
                  onChanged: (val) {
                    if (val.isNotEmpty && _selectedTopic.isNotEmpty) {
                      setState(() {
                        _selectedTopic = '';
                      });
                    }
                  },
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(fontSize: 16, color: onSurfaceColor),
                  decoration: InputDecoration(
                    hintText: "Tell us what's on your mind...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Popular Topics
              Text(
                'POPULAR TOPICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: onSurfaceVariantColor,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _popularTopics.map((topic) {
                  final isSelected = _selectedTopic == topic;
                  return ChoiceChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTopic = selected ? topic : '';
                        if (selected) {
                          _topicController.clear();
                        }
                      });
                    },
                    backgroundColor: surfaceColor,
                    selectedColor: primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : onSurfaceColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? primaryColor : borderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),
              
              // Start Chat Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Chat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
