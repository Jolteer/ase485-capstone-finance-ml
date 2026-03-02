/// Represents an authenticated user's profile information.
/// 
/// This model contains the core user data including identification,
/// contact information, and account creation timestamp.
class User {
  /// Unique identifier for the user.
  final String id;
  
  /// User's email address used for authentication and communication.
  final String email;
  
  /// Display name for the user.
  final String name;
  
  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// Creates a new [User] instance.
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  /// Creates a [User] instance from a JSON map.
  /// 
  /// Expects keys: 'id', 'email', 'name', and 'created_at'.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [User] instance to a JSON map.
  /// 
  /// Returns a map with keys: 'id', 'email', 'name', and 'created_at'.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [User] with the given fields replaced.
  /// 
  /// Any field left as null will retain its current value.
  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, email, name, createdAt);

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
