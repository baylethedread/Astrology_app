import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickAccessCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('QuickAccessCard - Applying text color: Colors.black, isDarkMode: $isDarkMode'); // Debug print

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[200] : Theme.of(context).cardTheme.color, // Light background in dark mode
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.black), // Force black color
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: Colors.black, // Explicitly set to black
                  ),
                  maxLines: 2, // Allow up to two lines for the line break
                  // Removed overflow: TextOverflow.ellipsis since line break handles visibility
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}