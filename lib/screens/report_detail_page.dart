import 'package:flutter/material.dart';
import 'package:ecowatch/models/report.dart';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;
  const ReportDetailPage({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(report.category),
        backgroundColor: Colors.grey[850],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionCard('Your Submission', [
            _buildDetailRow('Description:', report.description),
            _buildDetailRow(
              'Location:',
              '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('AI Analysis', [
            _buildDetailRow(
              'Location Verification:',
              report.locationVerification,
              highlightColor: _getVerificationColor(
                report.locationVerification,
              ),
            ),
            _buildDetailRow(
              'Image Verification:',
              report.imageVerification,
              highlightColor: _getVerificationColor(report.imageVerification),
            ),
            _buildDetailRow(
              'Location Remarks:',
              report.aiAnalysis['location_remarks'] ?? 'N/A',
            ),
            _buildDetailRow(
              'Category Remarks:',
              report.aiAnalysis['category_remarks'] ?? 'N/A',
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Score Breakdown', [
            _buildDetailRow(
              'Image Score:',
              '${report.gamification['image_score'] ?? 0} / 50',
            ),
            _buildDetailRow(
              'Description Score:',
              '${report.gamification['description_score'] ?? 0} / 20',
            ),
            _buildDetailRow(
              'Category Score:',
              '${report.gamification['category_score'] ?? 0} / 10',
            ),
            _buildDetailRow(
              'Geo-Tag Score:',
              '${report.gamification['geo_score'] ?? 0} / 10',
            ),
            _buildDetailRow(
              'Bonus:',
              '${report.gamification['bonus_adjustment'] ?? 0}',
            ),
            _buildDetailRow(
              'Remarks:',
              report.gamification['remarks'] ?? 'N/A',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Total Score: ${report.totalScore}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reported on ${DateFormat.yMMMd().add_jm().format(report.createdAt.toDate())}',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Colors.teal, thickness: 1, height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: highlightColor ?? Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getVerificationColor(String verification) {
    switch (verification.toLowerCase()) {
      case 'location verified':
      case 'consistent':
        return Colors.greenAccent;
      case 'inconsistent':
      case 'not in mangrove region':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }
}
