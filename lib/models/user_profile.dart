import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model for our user profile stored in Firestore.
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String role;
  final int points;
  final String badges;

  /// Constructor that initializes all the final fields.
  /// The 'required' keyword ensures they are all provided when a UserProfile is created.
  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.points,
    required this.badges,
  });

  /// Factory constructor to create a UserProfile from a Firestore document.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      points: data['points'] ?? 0,
      badges: data['badges'] ?? '',
    );
  }
}

