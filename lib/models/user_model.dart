class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String username;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    this.avatarUrl,
  });

  UserModel copyWith({
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
