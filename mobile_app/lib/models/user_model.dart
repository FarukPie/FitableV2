class User {
  final String id;
  final String email;
  final String? accessToken;

  User({
    required this.id,
    required this.email,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if the user structure is nested under "user" key or flat
    // The backend login return structure: { "data": { "user": {id, email}, "access_token": ... } } 
    // Wait, my backend implementation returns { "user": {id, email}, "access_token": ..., "status": "success" } directly.
    
    // Let's handle both just in case, or stick to the one I implemented.
    // Implemented: 
    // { 
    //   "status": "success", 
    //   "access_token": "...", 
    //   "user": { "id": "...", "email": "..." } 
    // }

    final userObj = json['user'] as Map<String, dynamic>;
    return User(
      id: userObj['id'],
      email: userObj['email'],
      accessToken: json['access_token'],
    );
  }
}
