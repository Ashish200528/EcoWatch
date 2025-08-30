import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecowatch/models/user_profile.dart';
import 'package:ecowatch/models/report.dart';

// This class handles all interactions with Firebase services.
class AppService {
  // Singleton pattern to ensure only one instance of AppService is created.
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;

  AppService._internal();

  // Firebase service instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late FirebaseFirestore _firestore; // For our secondary database project

  bool _secondaryAppInitialized = false;

  // --- INITIALIZATION FOR TWO-PROJECT SETUP ---

  Future<void> _initializeSecondaryApp() async {
    if (_secondaryAppInitialized) return;

    try {
      const FirebaseOptions firestoreOptions = FirebaseOptions(
        apiKey: "AIzaSyBNeSFmYV5cI3WW6N8ZIF9J6HJDHwqCOyU",
        appId: "1:732511249252:web:53a7923f0137d73e20d071",
        messagingSenderId: "732511249252",
        projectId: "ecowatch-470604",
        authDomain: "ecowatch-470604.firebaseapp.com",
        storageBucket: "ecowatch-470604.appspot.com",
      );

      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'FirestoreApp',
        options: firestoreOptions,
      );

      _firestore = FirebaseFirestore.instanceFor(app: secondaryApp);
      _secondaryAppInitialized = true;
      print(
        "SUCCESS: Secondary Firestore connection initialized to project ecowatch-470604.",
      );
    } catch (e) {
      print("!!! CRITICAL: FAILED to initialize secondary Firebase app: $e");
    }
  }

  // --- AUTHENTICATION METHODS ---

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // A stream to listen for changes in the authentication state (login/logout).
  Stream<User?> get userChanges => _auth.authStateChanges();

  // --- FIRESTORE METHODS (for user profiles) ---

  Future<bool> doesUserProfileExist(String uid) async {
    await _initializeSecondaryApp();
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _initializeSecondaryApp();
    print("--- Creating Firestore Profile in project: ecowatch-470604 ---");
    // FIX: Changed profile.uuid to profile.uid
    await _firestore
        .collection('users')
        .doc(profile.uid)
        // FIX: The UserProfile model now has a toJson() method.
        .set(profile.toJson());
  }

  Stream<UserProfile?> getUserProfile(String uid) {
    _initializeSecondaryApp();
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          // FIX: The UserProfile model now has a fromJson() method.
          (snapshot) =>
              snapshot.exists ? UserProfile.fromJson(snapshot.data()!) : null,
        );
  }

  // --- FIRESTORE METHODS (for reports) ---
  Stream<List<Report>> getReportsForUser(String uid) {
    _initializeSecondaryApp();

    final reportsQuery = _firestore
        .collection('flutter_to_flask_to_Gemini')
        // FIX: The field in Firestore for the user ID is 'uuid', but our model uses 'uid'.
        // We query Firestore with 'uuid' to match the database schema.
        .where('uuid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return reportsQuery.snapshots().asyncMap((reportSnapshot) async {
      final List<Report> reports = [];
      for (final reportDoc in reportSnapshot.docs) {
        final reportData = reportDoc.data();
        final pkey = reportData['pkey'];

        final analysisQuery = await _firestore
            .collection('Gemini_to_Flask')
            .where('pkey', isEqualTo: pkey)
            .limit(1)
            .get();

        final gamificationQuery = await _firestore
            .collection('Gamification')
            .where('pkey', isEqualTo: pkey)
            .limit(1)
            .get();

        if (analysisQuery.docs.isNotEmpty &&
            gamificationQuery.docs.isNotEmpty) {
          reports.add(
            Report(
              pkey: pkey,
              uid: reportData['uuid'], // Matches Firestore field
              description: reportData['description'],
              category: reportData['category'],
              latitude: (reportData['latitude'] as num).toDouble(),
              longitude: (reportData['longitude'] as num).toDouble(),
              createdAt: reportData['createdAt'] ?? Timestamp.now(),
              aiAnalysis: analysisQuery.docs.first.data(),
              gamification: gamificationQuery.docs.first.data(),
            ),
          );
        }
      }
      return reports;
    });
  }
}
