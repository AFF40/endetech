import 'package:endetech/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.auditLog),
      ),
      body: Center(
        child: Text(strings.auditLogScreenBody),
      ),
    );
  }
}
