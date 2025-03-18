import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For AnnotatedRegion
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:astrology_ui/constants/const.dart';
import 'package:astrology_ui/theme/app_theme.dart'; // Import the theme file

class ChatbotScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  ChatbotScreen({required this.userProfile});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [
    {'sender': 'AstroBot', 'text': 'Hey there! I’m AstroBot, your astrology buddy. What’s on your mind?', 'timestamp': '10:00'},
  ];
  final List<Messages> _conversationHistory = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  late OpenAI _openAI;

  @override
  void initState() {
    super.initState();
    _openAI = OpenAI.instance.build(
      token: openAIAPIKey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
      enableLog: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      FocusScope.of(context).requestFocus(_focusNode);
      print('Focus requested on _focusNode');
    });

    _conversationHistory.add(Messages(
      role: Role.system,
      content: 'You are AstroBot, an astrology expert. The user is a ${widget.userProfile['zodiac_sign'] ?? 'unknown zodiac sign'} born on ${widget.userProfile['birth_date'] ?? 'unknown date'}. Provide astrology-related responses based on this profile.',
    ));
    _conversationHistory.add(Messages(
      role: Role.assistant,
      content: 'Hey there! I’m AstroBot, your astrology buddy. What’s on your mind?',
    ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'sender': 'You',
        'text': message.trim(),
        'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
      });
      _scrollToBottom();
    });

    _conversationHistory.add(Messages(
      role: Role.user,
      content: message.trim(),
    ));

    _getChatResponse();
  }

  Future<void> _getChatResponse() async {
    setState(() => _isTyping = true);

    try {
      // Convert List<Messages> to List<Map<String, dynamic>>
      final messagesForApi = _conversationHistory.map((msg) => {
        "role": msg.role.name, // Role.system -> "system", Role.user -> "user", etc.
        "content": msg.content,
      }).toList();

      // Create the chat completion request
      final request = ChatCompleteText(
        messages: messagesForApi, // Pass the converted list
        maxToken: 200,
        model: GptTurboChatModel(),
      );

      // Send request to OpenAI
      ChatCTResponse? response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        for (var element in response.choices) {
          if (element.message != null) {
            String botResponse = element.message!.content;
            setState(() {
              _messages.add({
                'sender': 'AstroBot',
                'text': botResponse,
                'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
              });
              _conversationHistory.add(Messages(
                role: Role.assistant,
                content: botResponse,
              ));
              _scrollToBottom();
            });
          }
        }
      } else {
        setState(() {
          _messages.add({
            'sender': 'AstroBot',
            'text': 'Sorry, I couldn’t generate a response. Please try again.',
            'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
          });
          _scrollToBottom();
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'AstroBot',
          'text': 'Error: $e',
          'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
        });
        _scrollToBottom();
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _conversationHistory.clear();
      _messages.add({
        'sender': 'AstroBot',
        'text': 'Chat cleared! Let’s start fresh—what’s up?',
        'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
      });
      _conversationHistory.add(Messages(
        role: Role.system,
        content: 'You are AstroBot, an astrology expert. The user is a ${widget.userProfile['zodiac_sign'] ?? 'unknown zodiac sign'} born on ${widget.userProfile['birth_date'] ?? 'unknown date'}. Provide astrology-related responses based on this profile.',
      ));
      _conversationHistory.add(Messages(
        role: Role.assistant,
        content: 'Chat cleared! Let’s start fresh—what’s up?',
      ));
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Chat with AstroBot",
          style: GoogleFonts.jetBrainsMono( // Replaced with JetBrains Mono
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getGradient(context),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
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
                                  style: GoogleFonts.jetBrainsMono( // Replaced with JetBrains Mono
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
                                style: GoogleFonts.jetBrainsMono( // Replaced with JetBrains Mono
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
                              style: GoogleFonts.jetBrainsMono( // Replaced with JetBrains Mono
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
                        focusNode: _focusNode,
                        autofocus: true,
                        style: GoogleFonts.jetBrainsMono( // Replaced with JetBrains Mono
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask AstroBot...',
                          hintStyle: GoogleFonts.jetBrainsMono( // Replaced with JetBrains Mono
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}