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
  int _tabIndex = 0;

  // === Menu per tab ===
  final Map<String, Map<String, bool>> _tabs = {
    'AIM': {
      'Aim Assist': false,
      'Aim Lock Head': false,
      'Aim Precision': false,
      'Auto Headshot': false,
      'Magic Bullet': false,
    },
    'ESP': {
      'ESP Player': false,
      'ESP Line': false,
      'ESP Box': false,
      'ESP Health': false,
      'Antenna': false,
    },
    'MISC': {
      'No Recoil': false,
      'Wall Hack': false,
      'Speed Hack': false,
      'Fly Hack': false,
    },
    'SET': {
      'Bypass Anti-Cheat': false,
      'Streamer Mode': false,
      'Hide Overlay': false,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IgnorePointer(
        // === KUNCI: cuma area bubble & panel yang nerima touch ===
        ignoring: false,
        child: Stack(
          children: [
            // Area kosong transparan yang gak nerima input
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.transparent),
              ),
            ),

            // Bubble
            if (!_panelOpen)
              Positioned(
                left: _pos.dx,
                top: _pos.dy,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() => _pos += d.delta),
                  onTap: () => setState(() => _panelOpen = true),
                  child: _buildBubble(),
                ),
              ),

            // Panel
            if (_panelOpen)
              Positioned(
                left: 8,
                top: 60,
                child: _buildPanel(),
              ),
          ],
        ),
      ),
    );
  }

  // === BUBBLE KECIL 36x36 ===
  Widget _buildBubble() {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(.9),
            blurRadius: 10, spreadRadius: 1,
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
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // === PANEL LANDSCAPE 16:9 (280 x 158) ===
  Widget _buildPanel() {
    const double w = 290;
    const double h = 170;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12).withOpacity(0.97),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.8), blurRadius: 14),
        ],
      ),
      child: Column(
        children: [
          // === HEADER ===
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF22222E))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset('assets/logo.jpg',
                        width: 14, height: 14, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.security,
                          color: Color(0xFFA855F7), size: 14),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('G CHEATS',
                      style: TextStyle(
                        color: Colors.white, fontSize: 10,
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
          ),

          // === TAB ROW ===
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF22222E))),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final name = _tabs.keys.elementAt(i);
                final active = _tabIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFA855F7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white54,
                            fontSize: 9,
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // === CONTENT (scrollable) ===
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Column(
                children: _tabs[_tabs.keys.elementAt(_tabIndex)]!
                    .entries
                    .map((e) => _menuRow(e.key, e.value))
                    .toList(),
              ),
            ),
          ),

          // === FOOTER BUTTONS ===
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF22222E))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _tabs[_tabs.keys.elementAt(_tabIndex)]!
                              .updateAll((k, v) => true);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA855F7),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      ),
                      child: const Text('ON',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _tabs[_tabs.keys.elementAt(_tabIndex)]!
                              .updateAll((k, v) => false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      ),
                      child: const Text('OFF',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(String label, bool value) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
          Transform.scale(
            scale: 0.5,
            child: Switch(
              value: value,
              activeColor: const Color(0xFFA855F7),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) {
                setState(() {
                  _tabs[_tabs.keys.elementAt(_tabIndex)]![label] = v;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
