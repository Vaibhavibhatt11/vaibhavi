// File: pages/profile/edit_profile_page.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required userName, required email});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String? _profileUrl;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc['fullName'] ?? '';
          _profileUrl = doc['profilePic'] ?? null;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
      await _uploadImage(File(picked.path));
    }
  }

  Future<void> _uploadImage(File file) async {
    final storageRef = FirebaseStorage.instance.ref().child("profile_images").child("${user!.uid}.jpg");
    await storageRef.putFile(file);
    String downloadUrl = await storageRef.getDownloadURL();

    // Update Firestore with new profile image URL
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'profilePic': downloadUrl,
    });

    setState(() {
      _profileUrl = downloadUrl;
    });
  }

  void _saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'fullName': _nameController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (_profileUrl != null
                    ? NetworkImage(_profileUrl!) as ImageProvider
                    : const AssetImage('assets/default_avatar.png')),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: const Icon(Icons.edit, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}