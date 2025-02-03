import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _relationshipStatusController = TextEditingController();
  String? _selectedZodiacSign;
  String? _selectedGender;
  String? _selectedDailyHoroscope;
  String? _selectedNotificationPreference;
  String? _selectedAstrologySystem;

  File? _profileImage; // Variable to hold the profile image

  // Lists for dropdown options
  final List<String> zodiacSigns = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
  ];

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> dailyHoroscopeOptions = ["Sun", "Moon", "Rising"];
  final List<String> notificationPreferences = ["Daily", "Weekly", "None"];
  final List<String> astrologySystems = ["Western", "Vedic", "Chinese"];

  // AI-driven personalization answers
  String? _lifeImprovement;
  bool _believeInPastLives = false;

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _selectedZodiacSign != null && _selectedGender != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'birthDate': _birthDateController.text,
          'birthTime': _birthTimeController.text,
          'location': _locationController.text,
          'interests': _interestsController.text,
          'relationshipStatus': _relationshipStatusController.text,
          'zodiacSign': _selectedZodiacSign,
          'gender': _selectedGender,
          'dailyHoroscope': _selectedDailyHoroscope,
          'notificationPreferences': _selectedNotificationPreference,
          'astrologySystem': _selectedAstrologySystem,
          'lifeImprovement': _lifeImprovement,
          'believeInPastLives': _believeInPastLives,
          'profileComplete': true,
          'profilePicture': _profileImage != null ? _profileImage!.path : null, // Store image path
        });

        // Navigate to Home Screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define the gradient colors for dark and light modes
    List<Color> gradientColors;
    if (isDarkMode) {
      gradientColors = [
        Color(0xFF0A0F29), // Deep space blue
        Color(0xFF1B1D3C), // Dark purple
        Color(0xFF3D2C8D), // Mystic violet
      ];
    } else {
      gradientColors = [
        Color(0xFF3A1C71), // Light purple
        Color(0xFFD76D77), // Light red
        Color(0xFFFFAF7B), // Peach
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: gradientColors[0],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 15),

                // Birth Date
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: "Birth Date",
                    suffixIcon: Icon(Icons.calendar_today, color: isDarkMode ? Colors.white : Colors.black),
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _birthDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  validator: (value) => value!.isEmpty ? "Select your birth date" : null,
                ),
                const SizedBox(height: 15),

                // Birth Time (Optional)
                TextFormField(
                  controller: _birthTimeController,
                  decoration: InputDecoration(
                    labelText: "Birth Time (Optional)",
                    suffixIcon: Icon(Icons.access_time, color: isDarkMode ? Colors.white : Colors.black),
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(height: 15),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Location",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter your location" : null,
                ),
                const SizedBox(height: 15),

                // Astrological Interests
                TextFormField(
                  controller: _interestsController,
                  decoration: InputDecoration(
                    labelText: "Astrological Interests (Optional)",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 15),

                // Relationship Status (Optional)
                TextFormField(
                  controller: _relationshipStatusController,
                  decoration: InputDecoration(
                    labelText: "Relationship Status (Optional)",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(height: 15),

                // Zodiac Sign (Optional)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Zodiac Sign (Optional)",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  value: _selectedZodiacSign,
                  items: zodiacSigns.map((sign) {
                    return DropdownMenuItem(
                      value: sign,
                      child: Text(sign),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedZodiacSign = value),
                  validator: (value) => value == null ? null : "Select your Zodiac Sign",
                ),
                const SizedBox(height: 15),

                // Gender
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Gender",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  value: _selectedGender,
                  items: genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? "Select your gender" : null,
                ),
                const SizedBox(height: 15),

                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.camera_alt, size: 30) : null,
                  ),
                ),
                const SizedBox(height: 30),

                // Save Profile Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientColors[1], // Corrected background color
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Save Profile"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
