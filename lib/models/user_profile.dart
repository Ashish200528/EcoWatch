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
  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.points,
    required this.badges,
  });

  /// Factory constructor to create a UserProfile from a Firestore document map.
  factory UserProfile.fromJson(Map<String, dynamic> data) {
    return UserProfile(
      // The UID is not in the document data itself, so handle it separately or expect it in the map.
      // For this implementation, we assume it's passed into the map.
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      points: data['points'] ?? 0,
      badges: data['badges'] ?? '',
    );
  }

  /// Converts this UserProfile object into a Map format for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'points': points,
      'badges': badges,
    };
  }
}
