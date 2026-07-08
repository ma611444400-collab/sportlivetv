import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SportLiveTvApp());
}

class SportLiveTvApp extends StatefulWidget {
  const SportLiveTvApp({super.key});
  @override
  State<SportLiveTvApp> createState() => _SportLiveTvAppState();
}

class _SportLiveTvAppState extends State<SportLiveTvApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemePref();
    NotificationService().init(FirebaseAuth.instance.currentUser?.uid);
  }

  Future<void> _loadThemePref() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  static _SportLiveTvAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SportLiveTvAppState>();

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportLiveTV',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      darkTheme: AppTheme.dark(),
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
