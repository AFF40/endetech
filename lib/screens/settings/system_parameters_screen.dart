import 'package:endetech/constants/app_strings.dart';
import 'package:flutter/material.dart';

class SystemParametersScreen extends StatelessWidget {
  const SystemParametersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.systemParameters),
      ),
      body: Center(
        child: Text(strings.systemParametersScreenBody),
      ),
    );
  }
}
