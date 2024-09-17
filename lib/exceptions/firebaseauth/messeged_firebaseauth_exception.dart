import 'package:firebase_auth/firebase_auth.dart';

abstract class MessagedFirebaseAuthException extends FirebaseAuthException {
  final String _message;

  MessagedFirebaseAuthException({
    required String code,
    String? message,
    String? email,
    AuthCredential? credential,
  })  : _message = message ?? '',
        super(
            code: code, message: message, email: email, credential: credential);

  @override
  String toString() {
    return _message.isNotEmpty ? _message : super.toString();
  }
}
