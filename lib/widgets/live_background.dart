import 'package:flutter/material.dart';
import 'dart:math';

class LiveBackground extends StatefulWidget {
  const LiveBackground({Key? key}) : super(key: key);

  @override
  _LiveBackgroundState createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<LiveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Star> stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Slower animation for smoother movement
    )..repeat();

    // Generate random stars
    final random = Random();
    for (int i = 0; i < 150; i++) { // Increased number of stars
      stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 2 + 1,
        opacity: random.nextDouble(),
        speed: random.nextDouble() * 0.005 + 0.002, // Random speed for movement
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('LiveBackground - isDarkMode: $isDarkMode'); // Debug print

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update star positions for movement
        for (var star in stars) {
          star.y += star.speed; // Move stars downward
          if (star.y > 1) {
            star.y = 0; // Reset to top when they reach the bottom
            star.x = Random().nextDouble(); // Randomize x position
          }
        }

        return CustomPaint(
          painter: StarryBackgroundPainter(
            animationValue: _controller.value,
            stars: stars,
            isDarkMode: isDarkMode,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Star {
  double x;
  double y;
  double radius;
  double opacity;
  double speed;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speed,
  });
}

class StarryBackgroundPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;
  final bool isDarkMode;

  StarryBackgroundPainter({
    required this.animationValue,
    required this.stars,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define gradients for light and dark modes
    final lightGradient = LinearGradient(
      colors: const [
        Color(0xFF3A1C71), // _lightPrimary
        Color(0xFFD76D77), // _lightSecondary
        Color(0xFFFFAF7B), // _lightAccent
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final darkGradient = LinearGradient(
      colors: const [
        Color(0xFF0A0F29), // _darkPrimary
        Color(0xFF1B1D3C), // _darkSecondary
        Color(0xFF3D2C8D), // _darkAccent
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Paint the gradient background
    final backgroundPaint = Paint()
      ..shader = isDarkMode ? darkGradient : lightGradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Paint the stars with twinkling and movement
    for (var star in stars) {
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(
          (star.opacity + sin(animationValue * 2 * pi + star.x * 2 * pi)) * 0.5, // More pronounced twinkling
        );
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        starPaint,
      );
    }

    // Add a dynamic nebula effect in dark mode
    if (isDarkMode) {
      final nebulaX = size.width * (0.5 + 0.3 * sin(animationValue * 2 * pi)); // Moving nebula
      final nebulaY = size.height * (0.5 + 0.2 * cos(animationValue * 2 * pi));
      final nebulaPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.purpleAccent.withOpacity(0.3 * (sin(animationValue * 2 * pi) * 0.5 + 0.5)),
            Colors.transparent,
          ],
          center: Alignment.center,
          radius: 0.7,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawCircle(
        Offset(nebulaX, nebulaY),
        size.width * 0.5,
        nebulaPaint,
      );
    }
  }

  @override
  bool shouldRepaint(StarryBackgroundPainter oldDelegate) => true;
}