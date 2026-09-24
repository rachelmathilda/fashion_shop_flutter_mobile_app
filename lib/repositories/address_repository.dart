import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

class AddressRepository {
  AddressRepository._();
  static final AddressRepository instance = AddressRepository._();

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses');

  Stream<List<AddressModel>> watchAll(String uid) {
    return _ref(
      uid,
    ).snapshots().map((s) => s.docs.map(AddressModel.fromFirestore).toList());
  }

  Future<AddressModel?> fetchDefault(String uid) async {
    final snap = await _ref(
      uid,
    ).where('isDefault', isEqualTo: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return AddressModel.fromFirestore(snap.docs.first);
  }

  Future<String> save(String uid, AddressModel address) async {
    if (address.isDefault) {
      final existing = await _ref(
        uid,
      ).where('isDefault', isEqualTo: true).get();
      for (final doc in existing.docs) {
        await doc.reference.update({'isDefault': false});
      }
    }
    final doc = await _ref(uid).add(address.toFirestore());
    return doc.id;
  }
}
