import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_strings.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../equipments/equipments_list_screen.dart';
import '../maintenances/maintenances_list_screen.dart';
import '../reports/datasheets_report_screen.dart';
import '../settings/audit_log_screen.dart';
import '../settings/system_parameters_screen.dart';
import '../settings/user_management_screen.dart';
import '../tasks/tasks_list_screen.dart';
import '../technicians/technicians_list_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('new_lib/constants/icons/logo-ende.png', height: 30),
        actions: const [_SettingsMenu()],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 510),
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: [
              _DashboardCard(
                icon: Icons.computer,
                title: strings.equipmentManagement,
                screen: const EquipmentsListScreen(),
              ),
              _DashboardCard(
                icon: Icons.people,
                title: strings.technicianManagement,
                screen: const TechniciansListScreen(),
              ),
              _DashboardCard(
                icon: Icons.calendar_today,
                title: strings.maintenancePlanning,
                screen: const MaintenancesListScreen(),
              ),
              _DashboardCard(
                icon: Icons.check_circle_outline,
                title: strings.taskManagement,
                screen: const TasksListScreen(),
              ),
              _DashboardCard(
                icon: Icons.bar_chart,
                title: strings.reports,
                screen: const DatasheetsReportScreen(),
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
      width: 150,
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
    final myAppState = MyApp.of(context);
    final strings = AppStrings.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'user_management':
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen()));
            break;
          case 'system_parameters':
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemParametersScreen()));
            break;
          case 'audit_log':
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AuditLogScreen()));
            break;
          case 'logout':
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            break;
          case 'toggle_dark_mode':
            myAppState.changeTheme(isDarkMode ? ThemeMode.light : ThemeMode.dark);
            break;
          case 'set_lang_en':
            myAppState.changeLanguage(const Locale('en'));
            break;
          case 'set_lang_es':
            myAppState.changeLanguage(const Locale('es'));
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'user_management',
          child: Text(strings.userManagement),
        ),
        PopupMenuItem<String>(
          value: 'system_parameters',
          child: Text(strings.systemParameters),
        ),
        PopupMenuItem<String>(
          value: 'audit_log',
          child: Text(strings.auditLog),
        ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem<String>(
          value: 'toggle_dark_mode',
          checked: isDarkMode,
          child: Text(strings.darkMode),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(value: 'set_lang_en', child: const Text('English')),
        PopupMenuItem<String>(value: 'set_lang_es', child: const Text('Español')),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Text(strings.logout),
        ),
      ],
    );
  }
}
