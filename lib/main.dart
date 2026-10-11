import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/panel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final logged = prefs.getBool('logged') ?? false;
  runApp(GCheatsApp(startLogged: logged));
}

class GCheatsApp extends StatelessWidget {
  final bool startLogged;
  const GCheatsApp({super.key, required this.startLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GCheats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF05050A),
        primaryColor: const Color(0xFFA855F7),
      ),
      home: startLogged ? const PanelScreen() : const LoginScreen(),
    );
  }
}
