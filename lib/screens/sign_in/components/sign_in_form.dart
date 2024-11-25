import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/exceptions/firebaseauth/messeged_firebaseauth_exception.dart';
import 'package:e_commerce_app_flutter/exceptions/firebaseauth/signin_exceptions.dart';
import 'package:e_commerce_app_flutter/screens/forgot_password/forgot_password_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../components/custom_suffix_icon.dart';
import '../../../components/default_button.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String snackbarMessage = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildForgotPasswordWidget(context),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: "Sign in",
            press: signInButtonCallback,
          ),
        ],
      ),
    );
  }

  Row buildForgotPasswordWidget(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen(),
                ));
          },
          child: Text(
            "Forgot Password",
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
      ),
      onSaved: (newValue) => email = newValue!,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        return null;
      },
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
      ),
      onSaved: (newValue) => password = newValue!,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        return null;
      },
    );
  }

  void signInButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Perform sign-in with email and password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Navigate to the next screen if sign-in is successful
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        print(e);
        if (e.code == 'user-not-found') {
          snackbarMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          snackbarMessage = 'Wrong password provided.';
        } else {
          snackbarMessage = e.code;
        }
        showSnackBar(snackbarMessage);
      } catch (e) {
        print(e);
        snackbarMessage = 'An error occurred. Please try again.';
        showSnackBar(snackbarMessage);
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
