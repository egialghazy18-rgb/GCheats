import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});
  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  static const _channel = MethodChannel('nzwx/overlay_bridge');

  bool _panelOpen = false;
  int _tabIndex = 0;

  // FOV
  bool _fovEnabled = false;
  double _fovRadius = 200;

  // Crosshair
  bool _crosshairEnabled = false;
  String _crosshairStyle = 'dot';
  double _crosshairSize = 20;

  // Game detected
  String _gameDetected = '';

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

  Offset _pos = const Offset(20, 200);

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_onMethod);
  }

  Future<dynamic> _onMethod(MethodCall call) async {
    switch (call.method) {
      case 'updateFov':
        setState(() {
          _fovEnabled = call.arguments['enabled'] ?? false;
          _fovRadius = (call.arguments['radius'] ?? 200).toDouble();
        });
        break;
      case 'updateCrosshair':
        setState(() {
          _crosshairEnabled = call.arguments['enabled'] ?? false;
          _crosshairStyle = call.arguments['style'] ?? 'dot';
          _crosshairSize = (call.arguments['size'] ?? 20).toDouble();
        });
        break;
      case 'updateGame':
        setState(() => _gameDetected = call.arguments['game'] ?? '');
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // === FOV CIRCLE (center layar) ===
          if (_fovEnabled)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FovPainter(radius: _fovRadius),
                ),
              ),
            ),

          // === CROSSHAIR (center layar) ===
          if (_crosshairEnabled)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CrosshairPainter(
                    style: _crosshairStyle,
                    size: _crosshairSize,
                  ),
                ),
              ),
            ),

          // === GAME BADGE (pojok kanan atas) ===
          if (_gameDetected.isNotEmpty)
            Positioned(
              right: 12, top: 40,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🎮 $_gameDetected',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // === BUBBLE ===
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

          // === PANEL ===
          if (_panelOpen)
            Positioned(
              left: 8,
              top: 60,
              child: _buildPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFFA855F7).withOpacity(.9), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: ClipOval(
        child: Image.asset('assets/logo.jpg', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFA855F7),
            child: const Center(child: Text('G',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      width: 290,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12).withOpacity(0.97),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.8), blurRadius: 14)],
      ),
      child: Column(
        children: [
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
                    ClipOval(child: Image.asset('assets/logo.jpg',
                      width: 14, height: 14, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.security,
                        color: Color(0xFFA855F7), size: 14))),
                    const SizedBox(width: 4),
                    const Text('G CHEATS',
                      style: TextStyle(color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    if (_gameDetected.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('• $_gameDetected',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 8)),
                    ],
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _panelOpen = false),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),

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
                        child: Text(name,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white54,
                            fontSize: 9,
                            fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Column(
                children: _tabs[_tabs.keys.elementAt(_tabIndex)]!
                    .entries.map((e) => _menuRow(e.key, e.value)).toList(),
              ),
            ),
          ),

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
                          _tabs[_tabs.keys.elementAt(_tabIndex)]!.updateAll((k, v) => true);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA855F7),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      ),
                      child: const Text('ON', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
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
                          _tabs[_tabs.keys.elementAt(_tabIndex)]!.updateAll((k, v) => false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      ),
                      child: const Text('OFF', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
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
                setState(() => _tabs[_tabs.keys.elementAt(_tabIndex)]![label] = v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// === FOV PAINTER ===
class _FovPainter extends CustomPainter {
  final double radius;
  _FovPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, paint);

    // Crosshair kecil di tengah FOV
    final dotPaint = Paint()..color = const Color(0xFFA855F7);
    canvas.drawCircle(center, 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _FovPainter old) => old.radius != radius;
}

// === CROSSHAIR PAINTER ===
class _CrosshairPainter extends CustomPainter {
  final String style;
  final double size;
  _CrosshairPainter({required this.style, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 2;

    if (style == 'dot') {
      canvas.drawCircle(center, this.size / 4, paint..style = PaintingStyle.fill);
    } else if (style == 'cross') {
      final half = this.size / 2;
      canvas.drawLine(Offset(center.dx - half, center.dy), Offset(center.dx + half, center.dy), paint);
      canvas.drawLine(Offset(center.dx, center.dy - half), Offset(center.dx, center.dy + half), paint);
    } else if (style == 'circle') {
      canvas.drawCircle(center, this.size / 2, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter old) =>
      old.style != style || old.size != size;
}
