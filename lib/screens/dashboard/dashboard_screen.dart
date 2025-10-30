import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/screens/auth/login_screen.dart';
import 'package:endetech/screens/equipments/equipments_list_screen.dart';
import 'package:endetech/screens/maintenances/maintenances_list_screen.dart';
import 'package:endetech/screens/reports/datasheets_report_screen.dart';
import 'package:endetech/screens/settings/audit_log_screen.dart';
import 'package:endetech/screens/settings/system_parameters_screen.dart';
import 'package:endetech/screens/settings/user_management_screen.dart';
import 'package:endetech/screens/tasks/tasks_list_screen.dart';
import 'package:endetech/screens/technicians/technicians_list_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: const [_SettingsMenu()],
      ),
      body: Center(
        child: Container(
          // Constrain the width to control the number of columns and button size
          constraints: const BoxConstraints(maxWidth: 510), // (150 * 3) + (16 * 2) = 482. Extra for padding.
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0, // Horizontal space between cards
            runSpacing: 16.0, // Vertical space between rows
            alignment: WrapAlignment.center,
            children: const [
              _DashboardCard(
                icon: Icons.computer,
                title: AppStrings.equipmentManagement,
                screen: EquipmentsListScreen(),
              ),
              _DashboardCard(
                icon: Icons.people,
                title: AppStrings.technicianManagement,
                screen: TechniciansListScreen(),
              ),
              _DashboardCard(
                icon: Icons.calendar_today,
                title: AppStrings.maintenancePlanning,
                screen: MaintenancesListScreen(),
              ),
              _DashboardCard(
                icon: Icons.check_circle_outline,
                title: AppStrings.taskManagement,
                screen: TasksListScreen(),
              ),
              _DashboardCard(
                icon: Icons.bar_chart,
                title: AppStrings.reports,
                screen: DatasheetsReportScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.screen,
  });

  final IconData icon;
  final String title;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // This fixed width is the key to preventing growth
      height: 135,
      child: Card(
        elevation: 4.0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32.0, color: Theme.of(context).primaryColor),
                const SizedBox(height: 8.0),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case AppStrings.userManagement:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserManagementScreen()),
            );
            break;
          case AppStrings.systemParameters:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SystemParametersScreen()),
            );
            break;
          case AppStrings.auditLog:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuditLogScreen()),
            );
            break;
          case AppStrings.logout:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: AppStrings.userManagement,
          child: Text(AppStrings.userManagement),
        ),
        const PopupMenuItem<String>(
          value: AppStrings.systemParameters,
          child: Text(AppStrings.systemParameters),
        ),
        const PopupMenuItem<String>(
          value: AppStrings.auditLog,
          child: Text(AppStrings.auditLog),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: AppStrings.logout,
          child: Text(AppStrings.logout),
        ),
      ],
    );
  }
}
