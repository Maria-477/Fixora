class RegisterRequest {
  final String phone;
  final String password;
  final String userType;
  final String fullName;

  RegisterRequest({
    required this.phone,
    required this.password,
    required this.userType,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
        'user_type': userType,
        'full_name': fullName,
      };
}

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? mockOtp;
  final String? accessToken;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.mockOtp,
    this.accessToken,
  });
}