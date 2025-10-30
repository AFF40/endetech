import 'package:flutter/material.dart';

class TaskValidationScreen extends StatelessWidget {
  const TaskValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Validation'),
      ),
      body: const Center(
        child: Text('Task Validation Screen'),
      ),
    );
  }
}
