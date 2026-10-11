import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/shizuku_service.dart';
import '../services/cheat_service.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});
  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  bool _shizukuReady = false;
  bool _overlayGranted = false;
  bool _overlayActive = false;
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
    _initAll();
  }

  Future<void> _initAll() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    final shizuku = await ShizukuService.requestPermission();

    setState(() {
      _overlayGranted = granted;
      _shizukuReady = shizuku;
      _checking = false;
    });

    if (!granted) {
      _requestOverlayPermission();
    }
  }

  Future<void> _requestOverlayPermission() async {
    await FlutterOverlayWindow.requestPermission();
    await Future.delayed(const Duration(seconds: 1));
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    setState(() => _overlayGranted = granted);
  }

  Future<void> _showOverlay() async {
    if (!_overlayGranted) {
      _requestOverlayPermission();
      return;
    }

    if (_overlayActive) {
      await FlutterOverlayWindow.closeOverlay();
      setState(() => _overlayActive = false);
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: false,
      overlayTitle: 'GCheats',
      overlayContent: 'Panel aktif',
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      height: WindowSize.fullCover,
      width: WindowSize.fullCover,
      startPosition: const OverlayPosition(0, 0),
    );
    setState(() => _overlayActive = true);
  }

  void _toggle(String key, bool val) async {
    setState(() => _menus[key] = val);
    await CheatService.sendToggle(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A12),
        title: const Text('G CHEATS', style: TextStyle(letterSpacing: 4, color: Colors.white)),
      ),
      body: _checking
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)))
        : Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(
                    child: Image.asset('assets/logo.jpg', fit: BoxFit.contain),
                  ),
                ),
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _overlayGranted ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _overlayGranted
                            ? '✓ Izin overlay OK'
                            : '⚠ Butuh izin "Tampilkan di atas aplikasi lain"',
                          style: TextStyle(
                            color: _overlayGranted ? Colors.greenAccent : Colors.orangeAccent,
                            fontSize: 13, fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_overlayGranted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _requestOverlayPermission,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                              child: const Text('MINTA IZIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showOverlay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _overlayActive ? Colors.redAccent : const Color(0xFFA855F7),
                            ),
                            child: Text(
                              _overlayActive ? 'SEMBUNYIKAN OVERLAY' : 'TAMPILKAN OVERLAY',
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _shizukuReady ? Colors.greenAccent : Colors.redAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shizuku', style: TextStyle(color: Colors.white, fontSize: 13)),
                        Text(
                          _shizukuReady ? '● OK' : '● OFFLINE',
                          style: TextStyle(
                            color: _shizukuReady ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 12, fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._menus.keys.map((k) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13131A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF22222E)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(k, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          Switch(
                            value: _menus[k]!,
                            activeColor: const Color(0xFFA855F7),
                            onChanged: (v) => _toggle(k, v),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
    );
  }
}
