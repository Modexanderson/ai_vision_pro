import 'package:flutter/material.dart';

import '../models/detection_result.dart';

class ExportOptionsSheet extends StatelessWidget {
  final DetectionResult result;

  const ExportOptionsSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('Export as PDF'),
            subtitle: const Text('Detailed report with images'),
            onTap: () => _exportAsPDF(context),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Export as CSV'),
            subtitle: const Text('Spreadsheet format'),
            onTap: () => _exportAsCSV(context),
          ),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.blue),
            title: const Text('Export as JSON'),
            subtitle: const Text('Raw data format'),
            onTap: () => _exportAsJSON(context),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting as PDF...')),
    );
  }

  void _exportAsCSV(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting as CSV...')),
    );
  }

  void _exportAsJSON(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting as JSON...')),
    );
  }
}
