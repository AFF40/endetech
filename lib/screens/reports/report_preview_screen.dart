import 'package:endetech/constants/app_strings.dart';
import 'package:flutter/material.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would pass the filtered data to this screen
    // For now, we'll just show a placeholder
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reportPreview),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // TODO: Implement PDF export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting to PDF...')),
              );
            },
            tooltip: AppStrings.exportToPDF,
          ),
        ],
      ),
      body: const Center(
        child: Text('Report preview will be displayed here.'),
      ),
    );
  }
}
