/// Represents an authenticated user.
class User {
  final String id;
  final String email;
  final String name;
  final double? monthlyIncome;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.monthlyIncome,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble(),
    );
  }
}
