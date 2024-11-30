import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User.dart';
import '../models/Product.dart';
import '../models/Calender.dart';
import '../models/CropField.dart';

class UserDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User> streamUser(String id) {
    print(id);
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snapshot) => User.fromFirestore(snapshot));
  }

  Future<User?> getUser(String id) async {
    try {
      print(id);
      DocumentSnapshot snapshot = await _db.collection('users').doc(id).get();
      print(snapshot);
      if (!snapshot.exists) {
        return null; // Document does not exist
      }
      print("hello");
      return User.fromFirestore(snapshot);
    } catch (e) {
      // Log error or handle it as per your app's needs
      print('Error fetching user: $e');
      return null;
    }
  }

  // Stream<Product> streamProduct(String id) {
  //   return _db
  //       .collection('products')
  //       .doc(id)
  //       .snapshots()
  //       .map((snapshot) => Product.fromFirestore(snapshot));
  // }

  // Future<Product> getProduct(String id) async {
  //   DocumentSnapshot snapshot = await _db.collection('products').doc(id).get();
  //   return Product.fromFirestore(snapshot);
  // }

  Stream<CropField> streamCropField(String id) {
    return _db
        .collection('cropfields')
        .doc(id)
        .snapshots()
        .map((snapshot) => CropField.fromFirestore(snapshot));
  }

  Future<CropField> getCropField(String id) async {
    DocumentSnapshot snapshot =
        await _db.collection('cropfields').doc(id).get();
    return CropField.fromFirestore(snapshot);
  }

  Stream<Calender> streamCalender(String id) {
    return _db
        .collection('cropData')
        .doc("wheet")
        .snapshots()
        .map((snapshot) => Calender.fromFirestore(snapshot));
    // return _db
    //     .collection('cropData')
    //     .doc(id)
    //     .snapshots()
    //     .map((snapshot) => Calender.fromFirestore(snapshot));
  }
}
