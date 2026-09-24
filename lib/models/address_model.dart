import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String addressText;
  final double lat;
  final double lng;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.addressText,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  factory AddressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AddressModel(
      id: doc.id,
      addressText: data['addressText'] ?? '',
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'addressText': addressText,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }
}
