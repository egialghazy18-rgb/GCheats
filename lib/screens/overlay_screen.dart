import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});
  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  bool _panelOpen = false;
  Offset _pos = const Offset(20, 200);

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

  // === BUBBLE KECIL: 40x40 (dari 60) ===
  Widget _buildBubble() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(.9),
            blurRadius: 12, spreadRadius: 1,
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
              child: Text('G',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // === PANEL KECIL: 200px width (dari 280) ===
  Widget _buildPanel() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12).withOpacity(0.97),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.7), blurRadius: 14),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset('assets/logo.jpg',
                      width: 16, height: 16, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.security,
                        color: Color(0xFFA855F7), size: 16),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('G CHEATS',
                    style: TextStyle(
                      color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.bold, letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _panelOpen = false),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: const Color(0xFF22222E)),
          const SizedBox(height: 2),

          // Menu list
          ..._menus.keys.map((k) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(k, style: const TextStyle(color: Colors.white, fontSize: 9)),
                Transform.scale(
                  scale: 0.5,
                  child: Switch(
                    value: _menus[k]!,
                    activeColor: const Color(0xFFA855F7),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (v) => setState(() => _menus[k] = v),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 2),
          Container(height: 1, color: const Color(0xFF22222E)),
          const SizedBox(height: 4),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 22,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA855F7),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 22),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('AKTIF',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: SizedBox(
                  height: 22,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        for (var k in _menus.keys) _menus[k] = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 22),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('OFF',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
