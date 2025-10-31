import 'package:flutter/material.dart';

class SystemParametersScreen extends StatelessWidget {
  const SystemParametersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Parameters'),
      ),
      body: const Center(
        child: Text('System Parameters Screen'),
      ),
    );
  }
}
