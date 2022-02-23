import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  late String uid;
  late String name;
  late String email;
  late String role;
  late int coins;
  late String username;
  late String photoUrl;
  late Timestamp creationTime;
  late Timestamp lastSignInTime;

  CurrentUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.coins,
    required this.username,
    required this.photoUrl,
    required this.creationTime,
    required this.lastSignInTime,
  });
  factory CurrentUser.fromMap(data) {
    return CurrentUser(
      uid: data["uid"],
      name: data["name"],
      email: data["email"],
      role: data["role"],
      coins: data["coins"],
      username: data["userName"],
      photoUrl: data["photoUrl"],
      creationTime: data["creationTime"],
      lastSignInTime: data["lastSignInTime"],
    );
  }
}
