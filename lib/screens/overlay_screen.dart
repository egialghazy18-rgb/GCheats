import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});
  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  bool _panelOpen = false;

  final Map<String, bool> _menus = {
    'Aim Assist': false,
    'Aim Lock Head': false,
    'ESP Player': false,
    'ESP Line': false,
    'ESP Box': false,
    'No Recoil': false,
    'Wall Hack': false,
    'Speed Hack': false,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _panelOpen ? _buildPanel() : _buildBubble(),
    );
  }

  // Floating bulat kecil
  Widget _buildBubble() {
    return GestureDetector(
      onTap: () => setState(() => _panelOpen = true),
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFA855F7), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withOpacity(.7),
              blurRadius: 20, spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
        ),
      ),
    );
  }

  // Panel menu
  Widget _buildPanel() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12).withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.6), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('G CHEATS',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              GestureDetector(
                onTap: () => setState(() => _panelOpen = false),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF22222E)),
          const SizedBox(height: 8),

          // Menu list
          ..._menus.keys.map((k) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(k, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _menus[k]!,
                      activeColor: const Color(0xFFA855F7),
                      onChanged: (v) => setState(() => _menus[k] = v),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF22222E)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                  child: const Text('ACTIVATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (var k in _menus.keys) _menus[k] = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('OFF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
