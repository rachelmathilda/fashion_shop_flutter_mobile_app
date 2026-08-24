import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String language;
  final String? address;
  final double? addressLat;
  final double? addressLng;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.language = 'English',
    this.address,
    this.addressLat,
    this.addressLng,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      email: d['email'] ?? '',
      fullName: d['fullName'] ?? '',
      username: d['username'] ?? '',
      avatarUrl: d['avatarUrl'],
      language: d['language'] ?? 'English',
      address: d['address'],
      addressLat: (d['addressLat'] as num?)?.toDouble(),
      addressLng: (d['addressLng'] as num?)?.toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'fullName': fullName,
    'username': username,
    'avatarUrl': avatarUrl,
    'language': language,
    'address': address,
    'addressLat': addressLat,
    'addressLng': addressLng,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  UserModel copyWith({
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? language,
    String? address,
    double? addressLat,
    double? addressLng,
  }) => UserModel(
    id: id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    username: username ?? this.username,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    language: language ?? this.language,
    address: address ?? this.address,
    addressLat: addressLat ?? this.addressLat,
    addressLng: addressLng ?? this.addressLng,
    createdAt: createdAt,
  );
}
