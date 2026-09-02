import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}