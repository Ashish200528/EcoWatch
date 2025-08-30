import 'package:flutter/material.dart';
import 'package:ecowatch/models/report.dart';
import 'package:ecowatch/screens/report_detail_page.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  const ReportCard({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailPage(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildScoreCircle(),
              const SizedBox(width: 16),
              Expanded(child: _buildReportInfo()),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.tealAccent, width: 2),
      ),
      child: Text(
        '${report.totalScore}',
        style: const TextStyle(
          color: Colors.tealAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReportInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat.yMMMd().format(report.createdAt.toDate()),
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    );
  }
}
