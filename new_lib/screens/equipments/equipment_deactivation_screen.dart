import 'package:flutter/material.dart';

class EquipmentDeactivationScreen extends StatelessWidget {
  const EquipmentDeactivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate Equipment'),
      ),
      body: const Center(
        child: Text('Deactivate Equipment Screen'),
      ),
    );
  }
}
