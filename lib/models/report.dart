import 'package:cloud_firestore/cloud_firestore.dart';

// A comprehensive model for a single EcoWatch report.
class Report {
  final String pkey;
  final String uid;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final Timestamp createdAt; // From initial report

  // Data from AI Analysis
  final Map<String, dynamic> aiAnalysis;

  // Data from Gamification
  final Map<String, dynamic> gamification;

  Report({
    required this.pkey,
    required this.uid,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.aiAnalysis,
    required this.gamification,
  });

  // Helper getters for easier access in the UI
  int get totalScore => gamification['total_score'] ?? 0;
  String get locationVerification =>
      aiAnalysis['location_verification'] ?? 'N/A';
  String get imageVerification =>
      aiAnalysis['image_category_verification'] ?? 'N/A';
}
