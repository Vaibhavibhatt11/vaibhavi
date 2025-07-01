import 'dart:io';
import 'package:chatapp_final/helper/helper_function.dart';
import 'package:chatapp_final/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String email;

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  String imageUrl = "";
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        imageUrl = snapshot.data()?['profileImage'] ?? "";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String downloadUrl = imageUrl;

        // Upload image if selected
        if (selectedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_profile')
              .child('${user.uid}.jpg');
          await ref.putFile(selectedImage!);
          downloadUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': _nameController.text.trim(),
          'profileImage': downloadUrl,
        });

        // Update shared preferences
        await HelperFunctions.saveUserNameSF(_nameController.text.trim());

        showSnackbar(context, Colors.green, 'Profile updated successfully');

        Navigator.pop(context, true);
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null)
                  as ImageProvider?,
                  child: imageUrl.isEmpty && selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: textInputDecoration.copyWith(labelText: "Full Name"),
                validator: (val) => val!.isEmpty ? "Name can't be empty" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
