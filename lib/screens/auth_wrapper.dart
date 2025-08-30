import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_service.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'create_profile_page.dart';

/// This widget is the gatekeeper of the app.
/// It listens to authentication changes and decides which screen to show.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    return StreamBuilder<User?>(
      stream: appService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authSnapshot.hasData) {
          // User is authenticated, now check if their profile exists in Firestore.
          final user = authSnapshot.data!;
          return FutureBuilder<bool>(
            future: appService.doesUserProfileExist(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (profileSnapshot.data == true) {
                // Profile exists, go to the home page.
                return HomePage(uid: user.uid);
              } else {
                // Profile does not exist, go to the create profile page.
                return CreateProfilePage(user: user);
              }
            },
          );
        }
        // User is not authenticated, show the login page.
        return const LoginPage();
      },
    );
  }
}
