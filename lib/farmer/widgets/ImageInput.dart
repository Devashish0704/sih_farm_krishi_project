import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/LightIconButton.dart';

class ImageInput extends StatefulWidget {
  final Function(File) selectImage;
  final String? imageUrl;
  final File? imageFile;
  final bool isEnglish;

  ImageInput(
    this.selectImage, {
    this.imageUrl,
    this.imageFile,
    this.isEnglish = true,
  });

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _storedImage;

  @override
  void initState() {
    super.initState();
    // Initialize _storedImage if widget.imageFile is provided
    _storedImage = widget.imageFile;
  }

  Future<void> _takePicture() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
      );
      if (pickedFile == null) return; // Early return if no image is picked

      setState(() {
        _storedImage = File(pickedFile.path);
      });

      widget.selectImage(_storedImage!);
    } catch (e) {
      print('Error taking picture: $e');
      // Optionally, show a user-friendly message
    }
  }

  Future<void> _uploadPicture() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
      if (pickedFile == null) return; // Early return if no image is picked

      setState(() {
        _storedImage = File(pickedFile.path);
      });

      widget.selectImage(_storedImage!);
    } catch (e) {
      print('Error uploading picture: $e');
      // Optionally, show a user-friendly message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          Text(
            widget.isEnglish ? "Add an Image" : "एक छवि जोड़ें",
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  right: 10,
                ),
                height: 100,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: (widget.imageUrl != null && _storedImage == null)
                    ? Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : _storedImage == null
                        ? Center(
                            child: Text(
                              widget.isEnglish ? "No Image" : "कोई तस्वीर नहीं",
                            ),
                          )
                        : Image.file(
                            _storedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                alignment: Alignment.center,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  LightIconButton(
                    icon: Icons.camera_alt,
                    text: widget.isEnglish ? "Camera" : "कैमरा",
                    function: _takePicture,
                  ),
                  LightIconButton(
                    icon: Icons.filter,
                    text: widget.isEnglish ? "Gallery" : "गेलरी",
                    function: _uploadPicture,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
