import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // Aliasing Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart'; // Your custom User model
import 'dart:io';
import '../widgets/ImageInput.dart'; // Ensure the correct path is used

class RegistrationScreen extends StatefulWidget {
  final auth.User firebaseUser; // Use the aliased version

  RegistrationScreen({required this.firebaseUser});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String city = '';
  String aadharNo = '';
  String imageUrl = ''; // Image URL after upload
  String fieldId = '';
  late Position location;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    location = await Geolocator.getCurrentPosition();
  }

  void _selectImage(File pickedImage) {
    setState(() {
      _selectedImage = pickedImage;
    });
  }

  Future<void> _uploadImage(File image) async {
    // Placeholder for image upload logic
    imageUrl =
        "https://www.kasandbox.org/programming-images/avatars/leaf-blue.png"; // Replace with actual URL
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure an image has been selected
      if (_selectedImage != null) {
        await _uploadImage(_selectedImage!);
      }

      // Create a new User object using your custom User model
      User newUser = User(
        userId: widget.firebaseUser.uid,
        name: name,
        age: age,
        phone: widget.firebaseUser.phoneNumber!,
        city: city,
        aadharNo: aadharNo,
        location: location,
        imageUrl: imageUrl,
        fieldId: fieldId,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.userId)
          .set({
        'name': newUser.name,
        'age': newUser.age,
        'phone': newUser.phone,
        'city': newUser.city,
        'aadharNumber': newUser.aadharNo,
        'location':
            GeoPoint(newUser.location.latitude, newUser.location.longitude),
        'imageUrl': newUser.imageUrl,
        'fieldId': newUser.fieldId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) => age = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                onSaved: (value) => city = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Aadhar Number'),
                onSaved: (value) => aadharNo = value!,
              ),
              SizedBox(height: 20),
              ImageInput(
                _selectImage,
                isEnglish: true, // Set to false if needed
                imageUrl:
                    imageUrl, // Display previously uploaded image if needed
                imageFile: _selectedImage, // Display currently selected image
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
