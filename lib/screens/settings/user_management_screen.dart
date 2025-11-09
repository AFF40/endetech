import 'package:endetech/constants/app_strings.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.userManagement),
      ),
      body: Center(
        child: Text(strings.userManagementScreenBody),
      ),
    );
  }
}
