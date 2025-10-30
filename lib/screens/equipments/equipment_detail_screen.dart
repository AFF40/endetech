import 'package:flutter/material.dart';

class EquipmentDetailScreen extends StatelessWidget {
  const EquipmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Detail'),
      ),
      body: const Center(
        child: Text('Equipment Detail Screen'),
      ),
    );
  }
}
