import 'dart:io';
import 'package:e_commerce_app_flutter/wrappers/authentification_wrapper.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../config.dart';
import '../routing/Application.dart';

class UserInfoProvider {
  static File? currentImage;
  static String currentImageUrl = "";

  static Future<void> uploadUserInfo({
    required BuildContext context,
    required String name,
    required String age,
    required String location,
    required String aadharNumber,
    Position? userPosition,
  }) async {
    if (name.isEmpty ||
        age.isEmpty ||
        location.isEmpty ||
        aadharNumber.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill up all the fields");
      return;
    }
    if (age.length != 2) {
      Fluttertoast.showToast(msg: "Please enter a valid age");
      return;
    }
    try {
      int newAge = int.parse(age);
      if (newAge < 18) {
        Fluttertoast.showToast(msg: "Please enter a valid age");
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Please enter a valid age");
    }
    if (aadharNumber.length != 12) {
      Fluttertoast.showToast(msg: "Please enter a 12-digit Aadhar Card Number");
      return;
    }
    if (userPosition == null) {
      userPosition =
          await Geolocator.getCurrentPosition(); // Default value for Position
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "User not authenticated");
      return;
    }
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'age': int.parse(age),
      'phone': user.phoneNumber,
      'city': location,
      'imageUrl': currentImageUrl.isEmpty ? STOCK_IMAGE_URL : currentImageUrl,
      'location': GeoPoint(userPosition.latitude, userPosition.longitude),
      'aadharNumber': aadharNumber,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("done dana dan"),
      ),
    );
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthentificationWrapper(),
        ));
  }

  static Future<void> takePicture(
      BuildContext context, Function notifyChanges) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) return;
    currentImage = File(imageFile.path);
    final Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('doctorProfilePictures/${Path.basename(currentImage!.path)}');
    final UploadTask uploadTask = firebaseStorageRef.putFile(currentImage!);
    await uploadTask.whenComplete(() => null);
    firebaseStorageRef.getDownloadURL().then((fileUrl) {
      currentImageUrl = fileUrl;
      notifyChanges();
    });
  }

  static Future<void> uploadPicture(
      BuildContext context, Function notifyChanges) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile == null) return;
    currentImage = File(imageFile.path);
    final Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('doctorProfilePictures/${Path.basename(currentImage!.path)}');
    final UploadTask uploadTask = firebaseStorageRef.putFile(currentImage!);
    await uploadTask.whenComplete(() => null);
    firebaseStorageRef.getDownloadURL().then((fileUrl) {
      currentImageUrl = fileUrl;
      notifyChanges();
    });
  }

  static Future<void> logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Application.router.navigateTo(context, '/', replace: true);
  }
}
