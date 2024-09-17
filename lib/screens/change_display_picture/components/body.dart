import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:e_commerce_app_flutter/services/local_files_access/local_files_access_service.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../provider_models/body_model.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChosenImage(),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<ChosenImage>(
                builder: (context, bodyState, child) {
                  return Column(
                    children: [
                      Text("Change Avatar", style: headingStyle),
                      SizedBox(height: getProportionateScreenHeight(40)),
                      GestureDetector(
                        child: buildDisplayPictureAvatar(context, bodyState),
                        onTap: () => getImageFromUser(context, bodyState),
                      ),
                      SizedBox(height: getProportionateScreenHeight(80)),
                      buildChosePictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      buildUploadPictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      buildRemovePictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(80)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDisplayPictureAvatar(
      BuildContext context, ChosenImage bodyState) {
    return StreamBuilder(
      stream: UserDatabaseHelper().currentUserDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          Logger().w("Error fetching data: ${snapshot.error}");
          return Center(child: Text("Error loading data"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return CircleAvatar(
            radius: SizeConfig.screenWidth * 0.3,
            backgroundColor: kTextColor.withOpacity(0.5),
          );
        }

        final data = snapshot.data as DocumentSnapshot;

        ImageProvider? backImage;
        if (bodyState.chosenImage != null) {
          backImage = MemoryImage(bodyState.chosenImage.readAsBytesSync());
        } else if (data != null) {
          final url = data[UserDatabaseHelper.DP_KEY] as String?;
          if (url != null) backImage = NetworkImage(url);
        }

        return CircleAvatar(
          radius: SizeConfig.screenWidth * 0.3,
          backgroundColor: kTextColor.withOpacity(0.5),
          backgroundImage: backImage,
        );
      },
    );
  }

  Future<void> getImageFromUser(
      BuildContext context, ChosenImage bodyState) async {
    String? path;
    String? snackbarMessage;
    try {
      //  path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("LocalFileHandlingException: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != null) {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(snackbarMessage)));
      }
    }
    if (path != null) {
      bodyState.setChosenImage = File(path);
    }
  }

  Widget buildChosePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Choose Picture",
      press: () => getImageFromUser(context, bodyState),
    );
  }

  Widget buildUploadPictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Upload Picture",
      press: () async {
        final Future uploadFuture =
            uploadImageToFirestorage(context, bodyState);
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(uploadFuture,
                message: Text("Updating Display Picture"));
          },
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Display Picture updated")));
      },
    );
  }

  Future<void> uploadImageToFirestorage(
      BuildContext context, ChosenImage bodyState) async {
    String? snackbarMessage;
    try {
      final downloadUrl = await FirestoreFilesAccess().uploadFileToPath(
        bodyState.chosenImage,
        UserDatabaseHelper().getPathForCurrentUserDisplayPicture(),
      );

      final uploadDisplayPictureStatus = await UserDatabaseHelper()
          .uploadDisplayPictureForCurrentUser(downloadUrl);
      if (uploadDisplayPictureStatus) {
        snackbarMessage = "Display Picture updated successfully";
      } else {
        throw "Couldn't update display picture due to unknown reason";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = "Something went wrong";
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackbarMessage ?? "Unknown error")));
    }
  }

  Widget buildRemovePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Remove Picture",
      press: () async {
        final Future removeFuture =
            removeImageFromFirestore(context, bodyState);
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(removeFuture,
                message: Text("Deleting Display Picture"));
          },
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Display Picture removed")));
        Navigator.pop(context);
      },
    );
  }

  Future<void> removeImageFromFirestore(
      BuildContext context, ChosenImage bodyState) async {
    String? snackbarMessage;
    try {
      final fileDeletedFromFirestore =
          await FirestoreFilesAccess().deleteFileFromPath(
        UserDatabaseHelper().getPathForCurrentUserDisplayPicture(),
      );
      if (!fileDeletedFromFirestore) {
        throw "Couldn't delete file from Storage, please retry";
      }

      final status =
          await UserDatabaseHelper().removeDisplayPictureForCurrentUser();
      if (status) {
        snackbarMessage = "Picture removed successfully";
      } else {
        throw "Couldn't remove picture due to unknown reason";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = "Something went wrong";
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackbarMessage ?? "Unknown error")));
    }
  }
}
