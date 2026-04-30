/// Logged-in user profile (identity and display info).
///
/// Supports JSON via [User.fromJson] / [toJson] and immutability via
/// [copyWith]. Used for the auth context, account screen, and any user-scoped
/// data.
library;

import 'package:ase485_capstone_finance_ml/core/json/json_helpers.dart';

/// Public user object embedded in auth responses.
///
/// JSON parsing goes through the shared helpers in
/// `core/json/json_helpers.dart` so a malformed server payload throws the
/// same structured [ArgumentError] you get from [Budget] or [Goal].
class User {
  /// Unique identifier for the user (e.g. from auth backend).
  final String id;

  /// User's email address (login and contact).
  final String email;

  /// Display name shown in the UI.
  final String name;

  /// When the account was created.
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  /// Creates a [User] from a JSON map (e.g. API response). Throws
  /// [ArgumentError] for missing or malformed fields.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: requireString(json, 'id'),
      email: requireString(json, 'email'),
      name: requireString(json, 'name'),
      createdAt: requireDateTime(json, 'created_at'),
    );
  }

  /// Converts this user to a JSON map (snake_case keys for API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Returns a copy of this user with the given fields replaced.
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
