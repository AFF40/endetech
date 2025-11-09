import 'package:endetech/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_strings.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;
  final languageCode = prefs.getString('language') ?? 'en';
  ApiService.setLanguage(languageCode);
  runApp(MyApp(isLoggedIn: isLoggedIn && keepLoggedIn));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');
    final language = prefs.getString('language');

    setState(() {
      if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (theme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }

      if (language == 'es') {
        _locale = const Locale('es');
      } else {
        _locale = const Locale('en');
      }
      ApiService.setLanguage(_locale.languageCode);
    });
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    String theme;
    if (themeMode == ThemeMode.dark) {
      theme = 'dark';
    } else if (themeMode == ThemeMode.light) {
      theme = 'light';
    } else {
      theme = 'system';
    }
    await prefs.setString('theme', theme);
    setState(() {
      _themeMode = themeMode;
    });
  }

  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    ApiService.setLanguage(locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.of(context).appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0033A0),
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0033A0),
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        _AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      home: widget.isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return locale.languageCode == 'es' ? EsStrings() : EnStrings();
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
