class UserMe {
  final int id;
  final String phone;
  final String userType;
  final bool isActive;
  final String? fullName;

  UserMe({
    required this.id,
    required this.phone,
    required this.userType,
    required this.isActive,
    this.fullName,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id'],
      phone: json['phone'],
      userType: json['user_type'],
      isActive: json['is_active'],
      fullName: json['full_name'],
    );
  }
}