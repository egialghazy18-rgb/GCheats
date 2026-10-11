import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});
  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  bool _panelOpen = false;
  Offset _pos = const Offset(30, 250);

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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (!_panelOpen)
            Positioned(
              left: _pos.dx,
              top: _pos.dy,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _pos += d.delta),
                onTap: () => setState(() => _panelOpen = true),
                child: _buildBubble(),
              ),
            )
          else
            Positioned(
              left: _pos.dx,
              top: _pos.dy,
              child: _buildPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFA855F7), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(.85),
            blurRadius: 18, spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFA855F7),
            child: const Center(
              child: Text('G', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12).withOpacity(0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.7), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset('assets/logo.jpg', width: 22, height: 22, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.security, color: Color(0xFFA855F7), size: 22)),
                  ),
                  const SizedBox(width: 6),
                  const Text('G CHEATS',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _panelOpen = false),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: const Color(0xFF22222E)),
          const SizedBox(height: 4),
          ..._menus.keys.map((k) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(k, style: const TextStyle(color: Colors.white, fontSize: 11)),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _menus[k]!,
                    activeColor: const Color(0xFFA855F7),
                    onChanged: (v) => setState(() => _menus[k] = v),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 4),
          Container(height: 1, color: const Color(0xFF22222E)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: const Text('AKTIF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
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
