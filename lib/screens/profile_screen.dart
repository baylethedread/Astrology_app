import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userProfile = await _userService.getUserProfile(user.uid);
      } else {
        _errorMessage = 'Please sign in to view your profile.';
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await _userService.updateUserProfile(
          userId: user.uid,
          name: _userProfile!['name'],
          birthDate: _userProfile!['birthDate'],
          birthTime: _userProfile!['birthTime'],
          location: _userProfile!['location'],
          zodiacSign: _userProfile!['zodiacSign'],
          profileImage: _newProfileImage,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        _fetchUserProfile(); // Refresh data
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally navigate to sign-in screen if not handled by Wrapper
      // Navigator.pushReplacementNamed(context, '/signin');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile', style: GoogleFonts.playfairDisplay()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: GoogleFonts.poppins()))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : _userProfile?['profileImageUrl'] != null
                      ? NetworkImage(_userProfile!['profileImageUrl'] as String)
                      : null as ImageProvider?,
                  child: _newProfileImage == null && _userProfile?['profileImageUrl'] == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _userProfile?['name'],
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => _userProfile?['name'] = value,
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _userProfile?['birthDate'],
                decoration: InputDecoration(labelText: 'Birth Date'),
                onChanged: (value) => _userProfile?['birthDate'] = value,
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _userProfile?['birthTime'],
                decoration: InputDecoration(labelText: 'Birth Time'),
                onChanged: (value) => _userProfile?['birthTime'] = value,
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _userProfile?['location'],
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) => _userProfile?['location'] = value,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _userProfile?['zodiacSign'],
                items: [
                  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio',
                  'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
                ].map((sign) => DropdownMenuItem(value: sign, child: Text(sign))).toList(),
                onChanged: (value) => setState(() => _userProfile?['zodiacSign'] = value),
                decoration: InputDecoration(labelText: 'Zodiac Sign'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signOut,
                child: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Distinct color for sign-out
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}