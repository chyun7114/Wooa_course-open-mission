class SignUpRequest {
  final String username;
  final String email;
  final String password;

  SignUpRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

class SignUpResponse {
  final bool success;
  final String? message;
  final dynamic data;

  SignUpResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'],
    );
  }
}

class SignInRequest {
  final String email;
  final String password;

  SignInRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignInResponse {
  final bool success;
  final String? accessToken;
  final String? message;
  final dynamic data;

  SignInResponse({
    required this.success,
    this.accessToken,
    this.message,
    this.data,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      success: json['success'] ?? true,
      accessToken: json['data']?['accessToken'],
      message: json['message'],
      data: json['data'],
    );
  }
}
