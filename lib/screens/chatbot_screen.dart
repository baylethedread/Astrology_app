import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For AnnotatedRegion
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:astrology_ui/theme/app_theme.dart'; // Import the theme file
import 'package:astrology_ui/services/chat_service.dart'; // Import the ChatService

// Define the CompatibilityResult model (can be moved to a separate file)
class CompatibilityResult {
  final int love;
  final int business;
  final int health;
  final String overall;
  final String loveDescription;
  final String businessDescription;

  CompatibilityResult({
    required this.love,
    required this.business,
    required this.health,
    required this.overall,
    required this.loveDescription,
    required this.businessDescription,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      love: int.tryParse(json['love'].toString()) ?? 50,
      business: int.tryParse(json['business'].toString()) ?? 50,
      health: int.tryParse(json['health'].toString()) ?? 50,
      overall: json['overall']?.toString() ?? 'Compatibility data unavailable.',
      loveDescription: json['loveDescription']?.toString() ?? 'No love description available.',
      businessDescription: json['businessDescription']?.toString() ?? 'No business description available.',
    );
  }

  String toFormattedString(String zodiacSign, String comparisonSign) {
    return '''
Compatibility between $zodiacSign and $comparisonSign:

Overall: $overall
Love ($love%): $loveDescription
Business ($business%): $businessDescription
Health ($health%)
    '''.trim();
  }
}

class ChatbotScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  ChatbotScreen({required this.userProfile});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'AstroBot',
      'text': '', // Will be set in initState
      'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
      'animationController': null,
    },
  ];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  late ChatService _chatService;
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();

    // Personalize the initial message using userProfile
    String welcomeMessage = widget.userProfile['zodiac_sign'] != null
        ? 'Hey there, ${widget.userProfile['zodiac_sign']}! I’m AstroBot, your astrology buddy. What’s on your mind?'
        : 'Hey there! I’m AstroBot, your astrology buddy. What’s on your mind?';
    _messages[0]['text'] = welcomeMessage;

    // Initialize animation controller for the initial message
    _messages[0]['animationController'] = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    // Initialize typing animation controller
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    // Ensure the scroll and focus happen after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      FocusScope.of(context).requestFocus(_focusNode);
      print('Focus requested on _focusNode');
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _addUserMessage(String message) {
    var animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    setState(() {
      _messages.add({
        'sender': 'You',
        'text': message.trim(),
        'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
        'animationController': animationController,
      });
      _scrollToBottom();
    });

    _getChatResponse(message);
  }

  Future<void> _getChatResponse(String message) async {
    setState(() {
      _isTyping = true;
    });

    try {
      // Include user profile information in the message for personalization
      String personalizedMessage = message;
      if (widget.userProfile['zodiac_sign'] != null && widget.userProfile['birth_date'] != null) {
        personalizedMessage = "I am a ${widget.userProfile['zodiac_sign']} born on ${widget.userProfile['birth_date']}. $message";
      } else if (widget.userProfile['zodiac_sign'] != null) {
        personalizedMessage = "I am a ${widget.userProfile['zodiac_sign']}. $message";
      }

      String botResponse;
      // Check if the message is a compatibility question
      RegExp compatibilityRegex = RegExp(r'compatible with (\w+)', caseSensitive: false);
      var match = compatibilityRegex.firstMatch(message);
      if (match != null && widget.userProfile['zodiac_sign'] != null) {
        String comparisonSign = match.group(1)!;
        // Call the /compatibility endpoint
        final result = await _chatService.getCompatibility(
          widget.userProfile['zodiac_sign'],
          comparisonSign,
        );

        // Convert the Map to a CompatibilityResult object
        final compatibilityResult = CompatibilityResult.fromJson(result);

        // Format the result as a string
        botResponse = compatibilityResult.toFormattedString(
          widget.userProfile['zodiac_sign'],
          comparisonSign,
        );
      } else {
        // Call the /chat endpoint for other messages
        botResponse = await _chatService.sendMessage(personalizedMessage);
      }

      var animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..forward();

      setState(() {
        _messages.add({
          'sender': 'AstroBot',
          'text': botResponse,
          'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
          'animationController': animationController,
        });
        _scrollToBottom();
      });
    } catch (e) {
      var animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..forward();

      setState(() {
        _messages.add({
          'sender': 'AstroBot',
          'text': 'Sorry, I’m unable to respond right now. Please try again later.',
          'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
          'animationController': animationController,
        });
        _scrollToBottom();
      });
      print('Error in _getChatResponse: $e');
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  void _clearChat() {
    setState(() {
      // Dispose of all animation controllers
      for (var message in _messages) {
        message['animationController']?.dispose();
      }
      _messages.clear();
      var animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      )..forward();
      String welcomeMessage = widget.userProfile['zodiac_sign'] != null
          ? 'Hey there, ${widget.userProfile['zodiac_sign']}! I’m AstroBot, your astrology buddy. What’s on your mind?'
          : 'Hey there! I’m AstroBot, your astrology buddy. What’s on your mind?';
      _messages.add({
        'sender': 'AstroBot',
        'text': welcomeMessage,
        'timestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
        'animationController': animationController,
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            "Chat with AstroBot",
            style: GoogleFonts.jetBrainsMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
            color: Colors.white,
          ),
        ],
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.getGradient(context),
              ),
            ),
            // Semi-transparent overlay for better readability
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // Main Content
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mascot for typing indicator (static, no bounce)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Colors.purple, Colors.blue],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Image.asset(
                                      'lib/assets/astro_buddy.png',
                                      width: 32,
                                      height: 32,
                                      errorBuilder: (context, error, stackTrace) => const Text(
                                        '🌟',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.withOpacity(0.2),
                                          Colors.blue.withOpacity(0.2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'AstroBot is typing',
                                          style: GoogleFonts.jetBrainsMono(
                                            color: Colors.white,
                                            fontSize: 14,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          children: List.generate(3, (dotIndex) {
                                            return FadeTransition(
                                              opacity: Tween<double>(begin: 0.3, end: 1.0).animate(
                                                CurvedAnimation(
                                                  parent: _typingAnimationController,
                                                  curve: Interval(
                                                    0.2 * dotIndex,
                                                    0.2 * (dotIndex + 1),
                                                    curve: Curves.easeInOut,
                                                  ),
                                                ),
                                              ),
                                              child: const Text(
                                                ' •',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }),
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

                      final message = _messages[index];
                      final isUser = message['sender'] == 'You';
                      return FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: message['text']!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Message copied to clipboard')),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isUser)
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Colors.purple, Colors.blue],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Image.asset(
                                        'lib/assets/astro_buddy.png',
                                        width: 32,
                                        height: 32,
                                        errorBuilder: (context, error, stackTrace) => const Text(
                                          '🌟',
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                  if (!isUser) const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isUser
                                                ? [Colors.blue, Colors.purple]
                                                : [
                                              Colors.purple.withOpacity(0.2),
                                              Colors.blue.withOpacity(0.2),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          message['text']!,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 15,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        message['timestamp']!,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          color: Colors.white70,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isUser) const SizedBox(width: 8),
                                  if (isUser)
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        'U',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Quick Reply Suggestions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSuggestionChip('Tell me about my zodiac sign'),
                        const SizedBox(width: 8),
                        _buildSuggestionChip('Check compatibility with Leo'),
                        const SizedBox(width: 8),
                        _buildSuggestionChip('What’s my horoscope today?'),
                      ],
                    ),
                  ),
                ),
                // Input Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ask AstroBot...',
                            hintStyle: GoogleFonts.jetBrainsMono(
                              color: Colors.white70,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _addUserMessage(value);
                              _messageController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ZoomIn(
                        duration: const Duration(milliseconds: 500),
                        child: Material(
                          color: Colors.transparent,
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
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: ActionChip(
        label: Text(
          suggestion,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 12,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.1),
        onPressed: () {
          _addUserMessage(suggestion);
          _messageController.clear();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    for (var message in _messages) {
      message['animationController']?.dispose();
    }
    super.dispose();
  }
}