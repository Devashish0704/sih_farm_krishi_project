import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreFilesAccess {
  FirestoreFilesAccess._privateConstructor();
  static final FirestoreFilesAccess _instance =
      FirestoreFilesAccess._privateConstructor();
  factory FirestoreFilesAccess() {
    return _instance;
  }

  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firestore {
    _firebaseFirestore ??= FirebaseFirestore.instance;
    return _firebaseFirestore!;
  }

  // Future<String> uploadFileToPath(File file, String path) async {
  //   print(file);
  //   print(path);
  //   final Reference firestorageRef = FirebaseStorage.instance.ref();
  //   final snapshot = await firestorageRef.child(path).putFile(file);
  //   final downloadUrl = await snapshot.ref.getDownloadURL();
  //   print(downloadUrl);
  //   return downloadUrl;
  // }
  Future<String> uploadFileToPath(File file, String path) async {
    // try {
    // Reference to Firebase Storage
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(path);
    print("1");
    // Upload the file
    final UploadTask uploadTask =
        firebaseStorageRef.putData(await file.readAsBytes());
    print("2");

    // Wait for the upload to complete
    await uploadTask.whenComplete(() => null);
    print("3");

    // Get the download URL
    final String downloadUrl = await firebaseStorageRef.getDownloadURL();
    print('Download URL: $downloadUrl');

    // Return the download URL
    return downloadUrl;
    // } catch (e) {
    //   print('Error uploading file: $e');
    //   throw e; // Rethrow the exception to handle it in the calling code
    // }
  }

  Future<bool> deleteFileFromPath(String path) async {
    final Reference firestorageRef = FirebaseStorage.instance.ref();
    try {
      await firestorageRef.child(path).delete();
      return true;
    } catch (e) {
      // Handle exceptions such as file not found
      print("Error deleting file: $e");
      return false;
    }
  }

  Future<String> getDeveloperImage() async {
    const filename = "about_developer/developer";
    List<String> extensions = <String>["jpg", "jpeg", "jpe", "jfif"];
    final Reference firestorageRef = FirebaseStorage.instance.ref();
    for (final ext in extensions) {
      try {
        final url =
            await firestorageRef.child("$filename.$ext").getDownloadURL();
        return url;
      } catch (_) {
        // Continue checking other extensions if one fails
        continue;
      }
    }
    throw FirebaseException(
        message: "No image found for Developer", plugin: 'Firebase Storage');
  }
}
