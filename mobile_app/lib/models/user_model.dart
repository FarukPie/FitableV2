class User {
  final String id;
  final String email;
  final String gender;
  final String? accessToken;
  final String? username;
  final String? fullName;

  User({
    required this.id,
    required this.email,
    required this.gender,
    this.accessToken,
    this.username,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if the user structure is nested under "user" key or flat
    final userObj = json['user'] as Map<String, dynamic>;
    final metadata = userObj['user_metadata'] as Map<String, dynamic>?;

    return User(
      id: userObj['id'],
      email: userObj['email'],
      // Check user_metadata first, then direct key, then fallback
      gender: metadata?['gender'] ?? userObj['gender'] ?? 'male', 
      username: metadata?['username'] ?? userObj['username'],
      fullName: metadata?['full_name'] ?? metadata?['fullName'] ?? userObj['full_name'] ?? userObj['fullName'],
      accessToken: json['access_token'],
    );
  }
}
