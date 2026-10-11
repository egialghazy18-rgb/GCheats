import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'panel_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String _err = '';

  static const _validUser = 'egi';
  static const _validPass = 'ganteng';

  Future<void> _login() async {
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 600));

    if (_user.text.trim() == _validUser && _pass.text.trim() == _validPass) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const PanelScreen()),
      );
    } else {
      setState(() { _err = 'ACCESS DENIED'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF05050A), Color(0xFF1A0B2E), Color(0xFF05050A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFA855F7), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withOpacity(.7),
                        blurRadius: 50, spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 26),
                const Text('G CHEATS',
                  style: TextStyle(
                    fontSize: 28, letterSpacing: 8,
                    color: Colors.white, fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text('FUTURISTIC PANEL v1.0',
                  style: TextStyle(color: Colors.white.withOpacity(.4), fontSize: 11, letterSpacing: 3),
                ),
                const SizedBox(height: 44),
                _field(_user, 'USERNAME', Icons.person_outline),
                const SizedBox(height: 14),
                _field(_pass, 'PASSWORD', Icons.lock_outline, obscure: true),
                if (_err.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_err, style: const TextStyle(color: Colors.redAccent, fontSize: 12, letterSpacing: 2)),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA855F7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('LOGIN', style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(.3), letterSpacing: 3, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFFA855F7)),
        filled: true,
        fillColor: const Color(0xFF13131A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
