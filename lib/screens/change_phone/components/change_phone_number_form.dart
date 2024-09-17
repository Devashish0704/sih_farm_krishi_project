import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../size_config.dart';

class ChangePhoneNumberForm extends StatefulWidget {
  const ChangePhoneNumberForm({Key? key}) : super(key: key);

  @override
  _ChangePhoneNumberFormState createState() => _ChangePhoneNumberFormState();
}

class _ChangePhoneNumberFormState extends State<ChangePhoneNumberForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPhoneNumberController =
      TextEditingController();
  final TextEditingController currentPhoneNumberController =
      TextEditingController();

  @override
  void dispose() {
    newPhoneNumberController.dispose();
    currentPhoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          buildCurrentPhoneNumberField(),
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          buildNewPhoneNumberField(),
          SizedBox(height: SizeConfig.screenHeight * 0.2),
          DefaultButton(
            text: "Update Phone Number",
            press: () async {
              final updateFuture = updatePhoneNumberButtonCallback();
              await showDialog(
                context: context,
                builder: (context) {
                  return AsyncProgressDialog(
                    updateFuture,
                    message: Text("Updating Phone Number"),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> updatePhoneNumberButtonCallback() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      bool status = false;
      String snackbarMessage = "Unknown error occurred";
      try {
        status = await UserDatabaseHelper()
            .updatePhoneForCurrentUser(newPhoneNumberController.text);
        if (status) {
          snackbarMessage = "Phone updated successfully";
        } else {
          snackbarMessage = "Couldn't update phone due to unknown reason";
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
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
  }

  Widget buildNewPhoneNumberField() {
    return TextFormField(
      controller: newPhoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: "Enter New Phone Number",
        labelText: "New Phone Number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.phone),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Phone Number cannot be empty";
        } else if (value.length != 10) {
          return "Only 10 digits allowed";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildCurrentPhoneNumberField() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserDatabaseHelper().currentUserDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Logger().w("Error fetching current phone number: ${snapshot.error}");
        }

        String? currentPhone;
        if (snapshot.hasData && snapshot.data != null) {
          currentPhone = snapshot.data
              ?.data()?['phone']; // Use the appropriate key for phone
        }

        if (currentPhone != null) {
          currentPhoneNumberController.text = currentPhone;
        }

        return TextFormField(
          controller: currentPhoneNumberController,
          decoration: InputDecoration(
            hintText: "No Phone Number available",
            labelText: "Current Phone Number",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: Icon(Icons.phone),
          ),
          readOnly: true,
        );
      },
    );
  }
}
