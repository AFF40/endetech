import 'package:flutter/material.dart';

class TasksReportScreen extends StatelessWidget {
  const TasksReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Report'),
      ),
      body: const Center(
        child: Text('Tasks Report Screen'),
      ),
    );
  }
}
