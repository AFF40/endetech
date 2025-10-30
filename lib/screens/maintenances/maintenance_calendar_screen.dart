import 'package:flutter/material.dart';

class MaintenanceCalendarScreen extends StatelessWidget {
  const MaintenanceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Calendar'),
      ),
      body: const Center(
        child: Text('Maintenance Calendar Screen'),
      ),
    );
  }
}
