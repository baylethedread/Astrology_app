// lib/services/user_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  // Fetch user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // Save user profile to Firestore (already used in ProfileSetupScreen)
  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String birthDate,
    required String birthTime,
    required String location,
    required String? zodiacSign,
    required File? profileImage,
  }) async {
    try {
      String? profileImageUrl;
      if (profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId');
        await storageRef.putFile(profileImage);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'birthDate': birthDate,
        'birthTime': birthTime,
        'location': location,
        'zodiacSign': zodiacSign,
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': true,
      });
    } catch (e) {
      throw Exception('Error saving profile: $e');
    }
  }

  // Update user profile (optional, for future use)
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? birthDate,
    String? birthTime,
    String? location,
    String? zodiacSign,
    File? profileImage,
  }) async {
    try {
      String? profileImageUrl;
      if (profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId');
        await storageRef.putFile(profileImage);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (birthDate != null) updateData['birthDate'] = birthDate;
      if (birthTime != null) updateData['birthTime'] = birthTime;
      if (location != null) updateData['location'] = location;
      if (zodiacSign != null) updateData['zodiacSign'] = zodiacSign;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}