import 'package:flutter/material.dart';
import 'package:ecowatch/models/user_profile.dart';
import 'package:ecowatch/services/app_service.dart';
import 'package:ecowatch/screens/upload_page.dart';
import '/screens/reports_history_page.dart';
import '/widgets/stat_card.dart';

class HomePage extends StatelessWidget {
  final String uid;
  const HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppService appService = AppService();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('EcoWatch Dashboard'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: appService.getUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Could not load user profile.'));
          }

          final userProfile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildWelcomeHeader(userProfile),
              const SizedBox(height: 24),
              _buildStatsGrid(userProfile),
              const SizedBox(height: 24),
              _buildActions(context, uid),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 22, color: Colors.grey[400]),
        ),
        Text(
          userProfile.name,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(UserProfile userProfile) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatCard(
          title: 'EcoPoints',
          value: userProfile.points.toString(),
          icon: Icons.star_rounded,
          color: Colors.amber,
        ),
        StatCard(
          title: 'Current Role',
          value: userProfile.role,
          icon: Icons.shield_rounded,
          color: Colors.lightBlue,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.history_rounded,
          label: 'View My Reports',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportsHistoryPage(uid: uid),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context: context,
          icon: Icons.camera_alt_rounded,
          label: 'Submit a New Report',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadPage(uid: uid)),
            );
          },
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? Colors.teal : Colors.grey[800],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
