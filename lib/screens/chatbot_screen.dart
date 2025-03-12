import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [
    {'sender': 'AstroBot', 'text': 'Hey there! I’m AstroBot, your astrology buddy. What’s on your mind?', 'timestamp': '10:00'},
  ];
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'sender': 'You',
        'text': message,
        'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5), // Safe timestamp
      });
    });
    _simulateBotResponse();
  }

  void _simulateBotResponse() {
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) { // Ensure widget is still mounted
        setState(() {
          _isTyping = false;
          _messages.add({
            'sender': 'AstroBot',
            'text': 'I’m still setting up my star charts! Try asking about your lucky number or color.',
            'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
          });
        });
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add({
        'sender': 'AstroBot',
        'text': 'Chat cleared! Let’s start fresh—what’s up?',
        'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat with AstroBot",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Typing',
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                final isUser = message['sender'] == 'You';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isUser
                                ? (isDarkMode ? Colors.blue[700] : Colors.blue[100])
                                : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message['text']!,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: isUser
                                  ? (isDarkMode ? Colors.white : Colors.black87)
                                  : (isDarkMode ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['timestamp']!,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask AstroBot...',
                      hintStyle: GoogleFonts.poppins(
                        color: isDarkMode ? Colors.white54 : Colors.black45,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25.0),
                    onTap: () {
                      if (_messageController.text.isNotEmpty) {
                        _addUserMessage(_messageController.text);
                        _messageController.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}