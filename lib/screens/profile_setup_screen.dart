import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? _selectedZodiacSign;
  File? _profileImage;
  String? _coordinates;

  final List<String> zodiacSigns = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
  ];

  Future<String?> _getCoordinatesFromLocation(String location) async {
    // Use Nominatim API to convert the location into coordinates
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(location)}&format=json&limit=1',
    );

    try {
      // Nominatim requires a User-Agent header to identify the app
      final response = await http.get(
        url,
        headers: {'User-Agent': 'YourAppName/1.0 (your.email@example.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = data[0]['lat'];
          final lon = data[0]['lon'];
          return '$lat,$lon'; // Format: "latitude,longitude"
        } else {
          throw Exception('Location not found');
        }
      } else {
        throw Exception('Failed to fetch coordinates: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching coordinates: $e')),
      );
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Profile'),
            content: const Text('Are you sure you want to save your profile with these details?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      // Show loading indicator while fetching coordinates
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Fetch coordinates for the entered location
      if (_locationController.text.isNotEmpty) {
        _coordinates = await _getCoordinatesFromLocation(_locationController.text);
        if (_coordinates == null) {
          Navigator.pop(context); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch location coordinates. Please try again.')),
          );
          return;
        }
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String? profileImageUrl;
          if (_profileImage != null) {
            final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
            await storageRef.putFile(_profileImage!);
            profileImageUrl = await storageRef.getDownloadURL();
          }

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': _nameController.text,
            'birthDate': _birthDateController.text,
            'birthTime': _birthTimeController.text,
            'birthLocation': _coordinates,
            'birthLocationName': _locationController.text, // Store the place name
            'zodiacSign': _selectedZodiacSign,
            'profileImageUrl': profileImageUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'profileComplete': true,
          });

          Navigator.pop(context); // Close the loading dialog
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          Navigator.pop(context); // Close the loading dialog
          String errorMessage = e.toString().contains('network')
              ? 'Network error, please try again later'
              : 'Error saving profile: $e';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInBytes = await file.length();
      if (sizeInBytes > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size should be less than 5MB')),
        );
        return;
      }
      setState(() {
        _profileImage = file;
      });
    }
  }

  String _calculateZodiacSign(DateTime birthDate) {
    final day = birthDate.day;
    final month = birthDate.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Aries";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Taurus";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "Gemini";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Cancer";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Leo";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Virgo";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "Libra";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return "Scorpio";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "Sagittarius";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "Capricorn";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Aquarius";
    return "Pisces";
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    List<Color> gradientColors = isDarkMode
        ? [Color(0xFF0A0F29), Color(0xFF1B1D3C), Color(0xFF3D2C8D)]
        : [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)];

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
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null ? Icon(Icons.camera_alt, size: 30) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 15),
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
                        _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        _selectedZodiacSign = _calculateZodiacSign(pickedDate);
                      });
                    }
                  },
                  validator: (value) => value == null || value.isEmpty ? "Select your birth date" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _birthTimeController,
                  decoration: InputDecoration(
                    labelText: "Birth Time",
                    suffixIcon: Icon(Icons.access_time, color: isDarkMode ? Colors.white : Colors.black),
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _birthTimeController.text = DateFormat('HH:mm').format(
                          DateTime(2023, 1, 1, pickedTime.hour, pickedTime.minute),
                        );
                      });
                    }
                  },
                  validator: (value) => value == null || value.isEmpty ? "Select your birth time" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Birth Location (e.g., New York)",
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter your birth location" : null,
                ),
                const SizedBox(height: 5),
                Text(
                  "Location data provided by OpenStreetMap (Nominatim).",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Zodiac Sign",
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
                  validator: (value) => value == null ? "Select your Zodiac Sign" : null,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradientColors[1],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Create Profile",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}