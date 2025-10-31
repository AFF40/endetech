import 'package:flutter/material.dart';

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: const Center(
        child: Text('Export Data Screen'),
      ),
    );
  }
}
