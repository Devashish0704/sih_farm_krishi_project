import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/AppReview.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';

class AppReviewDatabaseHelper {
  static const String APP_REVIEW_COLLECTION_NAME = "app_reviews";

  AppReviewDatabaseHelper._privateConstructor();
  static final AppReviewDatabaseHelper _instance =
      AppReviewDatabaseHelper._privateConstructor();
  factory AppReviewDatabaseHelper() {
    return _instance;
  }

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firebaseFirestore;

  Future<bool> editAppReview(AppReview appReview) async {
    final uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not logged in");
    }
    final docRef = firestore.collection(APP_REVIEW_COLLECTION_NAME).doc(uid);
    final docData = await docRef.get();
    if (docData.exists) {
      await docRef.update(appReview.toUpdateMap());
    } else {
      await docRef.set(appReview.toMap());
    }
    return true;
  }

  Future<AppReview> getAppReviewOfCurrentUser() async {
    final uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User is not logged in");
    }
    final docRef = firestore.collection(APP_REVIEW_COLLECTION_NAME).doc(uid);
    final docData = await docRef.get();
    if (docData.exists) {
      return AppReview.fromMap(docData.data()!, id: docData.id);
    } else {
      final appReview = AppReview(uid, liked: true, feedback: "");
      await docRef.set(appReview.toMap());
      return appReview;
    }
  }
}
