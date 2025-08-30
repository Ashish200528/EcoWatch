import 'package:flutter/material.dart';
import 'package:ecowatch/models/report.dart';
import 'package:ecowatch/services/app_service.dart';
import 'package:ecowatch/widgets/report_card.dart';

class ReportsHistoryPage extends StatelessWidget {
  final String uid;
  const ReportsHistoryPage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppService appService = AppService();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.grey[850],
      ),
      body: StreamBuilder<List<Report>>(
        stream: appService.getReportsForUser(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have not submitted any reports yet.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final reports = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return ReportCard(report: reports[index]);
            },
          );
        },
      ),
    );
  }
}
