import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'create_profile_page.dart';
import '../services/app_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // FIX: Changed authStateChanges to userChanges to match the getter in AppService.
      stream: AppService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return FutureBuilder<bool>(
            future: AppService().doesUserProfileExist(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (profileSnapshot.data == true) {
                return HomePage(uid: user.uid);
              } else {
                return CreateProfilePage(user: user);
              }
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
