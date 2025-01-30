import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Corrected import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String? _selectedZodiacSign;

  final List<String> zodiacSigns = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
  ];

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _selectedZodiacSign != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'birthDate': _birthDateController.text,
          'zodiacSign': _selectedZodiacSign,
          'profileComplete': true,
        });

        // Navigate to Home Screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: "Birth Date",
                  suffixIcon: Icon(Icons.calendar_today),
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
                validator: (value) =>
                value!.isEmpty ? "Select your birth date" : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Zodiac Sign"),
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Save Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
