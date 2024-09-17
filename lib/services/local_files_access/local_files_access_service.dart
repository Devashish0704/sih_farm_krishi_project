import 'dart:io';

import 'package:e_commerce_app_flutter/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> chooseImageFromLocalFiles(
  BuildContext context, {
  int maxSizeInKB = 1024,
  int minSizeInKB = 5,
}) async {
  final PermissionStatus photoPermissionStatus =
      await Permission.photos.request();
  // if (!photoPermissionStatus.isGranted) {
  //   throw LocalFileHandlingStorageReadPermissionDeniedException(
  //       message:
  //           "Permission required to read storage, please grant permission");
  // }

  final ImagePicker imgPicker = ImagePicker();
  final ImageSource? imgSource = await showDialog<ImageSource>(
    builder: (context) {
      return AlertDialog(
        title: Text("Choose image source"),
        actions: [
          TextButton(
            child: Text("Camera"),
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          TextButton(
            child: Text("Gallery"),
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      );
    },
    context: context,
  );

  if (imgSource == null) {
    throw LocalImagePickingInvalidImageException(
        message: "No image source selected");
  }

  final XFile? imagePicked = await imgPicker.pickImage(source: imgSource);

  if (imagePicked == null) {
    throw LocalImagePickingInvalidImageException();
  } else {
    final file = File(imagePicked.path);
    final fileLength = await file.length();

    // if (fileLength > (maxSizeInKB * 1024) ||
    //     fileLength < (minSizeInKB * 1024)) {
    //   throw LocalImagePickingFileSizeOutOfBoundsException(
    //       message:
    //           "Image size should be between ${minSizeInKB}KB and ${maxSizeInKB}KB");
    // } else {
    return imagePicked.path;
    //  }
  }
}
