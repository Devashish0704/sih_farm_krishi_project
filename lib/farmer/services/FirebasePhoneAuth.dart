import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PhoneAuthState {
  Initialized,
  Started,
  CodeSent,
  CodeResent,
  Verified,
  Failed,
  Error,
  AutoRetrievalTimeOut,
}

class FirebasePhoneAuth {
  static String? phone, actualCode;
  static AuthCredential? _authCredential;
  static final StreamController<String> statusStream =
      StreamController<String>.broadcast();
  static final StreamController<PhoneAuthState> phoneAuthState =
      StreamController<PhoneAuthState>.broadcast();
  static User? user;

  static void dispose() {
    statusStream.close();
    phoneAuthState.close();
  }

  static void init() {
    statusStream.stream.listen((String status) {
      print("PhoneAuthStatus: $status");
    });
  }

  static void startAuth({required String phoneNumber}) {
    phone = phoneNumber;

    addStatus('Phone Auth Started');
    addState(PhoneAuthState.Started);

    FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: phone!,
      timeout: Duration(seconds: 90),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    )
        .then((_) {
      print("Code Sent");
    }).catchError((err) {
      print(err);
      addState(PhoneAuthState.Error);
      addStatus("Error occurred: $err");
    });
  }

  static final PhoneCodeSent codeSent =
      (String verificationId, [int? forceResendingToken]) {
    actualCode = verificationId;
    addStatus("Code Sent to $phone");
    addState(PhoneAuthState.CodeSent);
  };

  static final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      (String verificationId) {
    actualCode = verificationId;
    addStatus("Auto retrieval timeout");
    addState(PhoneAuthState.AutoRetrievalTimeOut);
  };

  static final PhoneVerificationFailed verificationFailed =
      (FirebaseAuthException authException) {
    addStatus('Error: ${authException.message}');
    addState(PhoneAuthState.Error);
    if (authException.message != null) {
      if (authException.message!.contains('not authorized')) {
        addStatus("App not authorized");
      } else if (authException.message!.contains('Network')) {
        addStatus("Check Network Connection");
      } else {
        addStatus(authException.message!);
      }
    }
  };

  static final PhoneVerificationCompleted verificationCompleted =
      (AuthCredential auth) async {
    addStatus("Auto retrieving verification code");
    try {
      // UserCredential result =
      //     await FirebaseAuth.instance.signInWithCredential(auth);
      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(auth);
      if (result.user != null) {
        user = result.user; // Store user details¯¸
        addState(PhoneAuthState.Verified);
        addStatus("Authentication Success");
        onAuthSuccess(result.user!);
      } else {
        addState(PhoneAuthState.Failed);
        addStatus("Invalid Code");
      }
    } catch (err) {
      addState(PhoneAuthState.Error);
      addStatus("Something went wrong $err");
    }
  };

  static Future<void> signInWithPhoneNumber({required String smsCode}) async {
    _authCredential = PhoneAuthProvider.credential(
        verificationId: actualCode!, smsCode: smsCode);
    try {
      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(_authCredential!);
      user = result.user; // Store user details
      addState(PhoneAuthState.Verified);
      addStatus("Authentication Successful");
      onAuthSuccess(result.user!);
    } catch (err) {
      addState(PhoneAuthState.Error);
      addStatus("Something went wrong: $err");
    }
  }

  static void onAuthSuccess(User user) {
    print("Authentication Success");
    print("User ID: ${user.uid}");
    print("User Phone Number: ${user.phoneNumber}");

    // Here, you can add code to save additional user data to Firestore or any other database.
    // Example: Save user data to Firestore or Realtime Database
    // saveUserDataToDatabase(user);

    // Additional logic after successful authentication can be added here
  }

  static void addState(PhoneAuthState state) {
    phoneAuthState.sink.add(state);
    print(state);
  }

  static void addStatus(String s) {
    statusStream.sink.add(s);
    print(s);
  }
}
