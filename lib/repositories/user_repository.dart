import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('users');

  Future<void> createUser(UserModel user) async {
    await _col.doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> fetchById(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _col
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _col.doc(uid).update(data);
  }

  Future<void> updateLanguage(String uid, String language) async {
    await _col.doc(uid).update({'language': language});
  }

  Future<void> updateAddress(
    String uid, {
    required String address,
    double? lat,
    double? lng,
  }) async {
    await _col.doc(uid).update({
      'address': address,
      'addressLat': lat,
      'addressLng': lng,
    });
  }
}
