import 'package:flutter/material.dart';

class QuickAccessCard extends StatelessWidget {
  final String title;  // Title to display on the card
  final IconData icon; // Icon to display on the card
  final VoidCallback onTap; // Action when the card is tapped

  // Constructor to initialize the card widget with required data
  QuickAccessCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle tap action
      child: Card(
        color: Colors.blue[50],  // Light blue color for the card background
        elevation: 5,  // Add elevation for shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),  // Padding inside the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center content in the card
            children: [
              Icon(
                icon,  // Display the icon
                size: 40,  // Size of the icon
                color: Colors.blue,  // Icon color
              ),
              SizedBox(height: 10),  // Space between icon and text
              Text(
                title,  // Display the title
                style: TextStyle(
                  fontSize: 16,  // Font size for the title
                  fontWeight: FontWeight.bold,  // Bold font style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
