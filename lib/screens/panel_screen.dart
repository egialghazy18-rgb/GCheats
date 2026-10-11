import 'package:flutter/material.dart';
import '../services/shizuku_service.dart';
import '../services/cheat_service.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});
  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  bool _shizukuReady = false;
  bool _checking = true;

  final Map<String, bool> _menus = {
    'Aim Assist': false,
    'Aim Lock Head': false,
    'ESP Player': false,
    'ESP Line': false,
    'ESP Box': false,
    'No Recoil': false,
    'Wall Hack': false,
    'Speed Hack': false,
    'Auto Headshot': false,
    'Magic Bullet': false,
    'Antenna': false,
    'Fly Hack': false,
  };

  @override
  void initState() {
    super.initState();
    _initShizuku();
  }

  Future<void> _initShizuku() async {
    final ok = await ShizukuService.requestPermission();
    setState(() { _shizukuReady = ok; _checking = false; });
  }

  void _toggle(String key, bool val) async {
    if (!_shizukuReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shizuku belum aktif!')),
      );
      return;
    }
    setState(() => _menus[key] = val);
    await CheatService.sendToggle(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A12),
        title: const Text('G CHEATS', style: TextStyle(letterSpacing: 4, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _shizukuReady ? Colors.green.withOpacity(.2) : Colors.red.withOpacity(.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _shizukuReady ? Colors.greenAccent : Colors.redAccent),
                ),
                child: Text(
                  _shizukuReady ? '● SHIZUKU OK' : '● OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    color: _shizukuReady ? Colors.greenAccent : Colors.redAccent,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _checking
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: _menus.keys.map((k) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13131A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF22222E)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(k, style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1)),
                    Switch(
                      value: _menus[k]!,
                      activeColor: const Color(0xFFA855F7),
                      onChanged: (v) => _toggle(k, v),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
    );
  }
}
