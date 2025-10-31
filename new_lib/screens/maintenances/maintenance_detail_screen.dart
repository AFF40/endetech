import 'package:flutter/material.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Detail'),
      ),
      body: const Center(
        child: Text('Maintenance Detail Screen'),
      ),
    );
  }
}
