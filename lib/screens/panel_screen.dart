import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/shizuku_service.dart';
import '../services/cheat_service.dart';
import '../services/game_detector.dart';
import '../services/overlay_bridge.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});
  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> with WidgetsBindingObserver {
  bool _shizukuReady = false;
  bool _overlayGranted = false;
  bool _overlayActive = false;
  bool _checking = true;
  String? _detectedGame;

  // State fitur
  bool _fovEnabled = false;
  double _fovRadius = 200;
  bool _crosshairEnabled = false;
  String _crosshairStyle = 'dot';
  double _crosshairSize = 20;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GameDetector.stopWatching();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (mounted && granted != _overlayGranted) {
      setState(() => _overlayGranted = granted);
    }
  }

  Future<void> _initAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    final shizuku = await ShizukuService.requestPermission();
    if (!mounted) return;
    setState(() {
      _overlayGranted = granted;
      _shizukuReady = shizuku;
      _checking = false;
    });

    // Mulai deteksi game
    GameDetector.startWatching((game) {
      if (!mounted) return;
      setState(() => _detectedGame = game);
      OverlayBridge.sendGameDetected(game);
    });

    if (!granted) _requestOverlayPermission();
  }

  Future<void> _requestOverlayPermission() async {
    await FlutterOverlayWindow.requestPermission();
    await Future.delayed(const Duration(milliseconds: 1200));
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!mounted) return;
    setState(() => _overlayGranted = granted);
  }

  Future<void> _showOverlay() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!mounted) return;
    if (!granted) {
      setState(() => _overlayGranted = false);
      _requestOverlayPermission();
      return;
    }
    setState(() => _overlayGranted = true);

    if (_overlayActive) {
      await FlutterOverlayWindow.closeOverlay();
      setState(() => _overlayActive = false);
      return;
    }

    try {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        overlayTitle: 'GCheats Aktif',
        overlayContent: 'Panel GCheats sedang berjalan',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.none,
        height: WindowSize.fullCover,
        width: WindowSize.fullCover,
        startPosition: const OverlayPosition(0, 0),
      );
      if (!mounted) return;
      setState(() => _overlayActive = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal buka overlay: $e')),
      );
    }
  }

  void _toggleFov(bool v) {
    setState(() => _fovEnabled = v);
    OverlayBridge.sendFov(enabled: v, radius: _fovRadius);
  }

  void _changeFovRadius(double r) {
    setState(() => _fovRadius = r);
    OverlayBridge.sendFov(enabled: _fovEnabled, radius: r);
  }

  void _toggleCrosshair(bool v) {
    setState(() => _crosshairEnabled = v);
    OverlayBridge.sendCrosshair(
      enabled: v, style: _crosshairStyle, size: _crosshairSize,
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPermission,
          ),
        ],
      ),
      body: _checking
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)))
        : Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(child: Image.asset('assets/logo.jpg', fit: BoxFit.contain)),
                ),
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // === GAME DETECTED BANNER ===
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _detectedGame != null
                          ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
                          : [const Color(0xFF3F3F46), const Color(0xFF52525B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _detectedGame != null ? Icons.sports_esports : Icons.search,
                          color: Colors.white, size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _detectedGame != null
                              ? '🎮 Game terdeteksi: $_detectedGame'
                              : 'Mencari game... buka FF / ML sekarang',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === OVERLAY CONTROL ===
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 14),
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
                          _overlayGranted ? '✓ Izin overlay OK' : '⚠ Butuh izin overlay',
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
                              child: const Text('MINTA IZIN',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

                  // === FOV CIRCLE ===
                  _sectionCard(
                    title: 'FOV CIRCLE',
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Aktifkan FOV', style: TextStyle(color: Colors.white, fontSize: 13)),
                          Switch(
                            value: _fovEnabled,
                            activeColor: const Color(0xFFA855F7),
                            onChanged: _toggleFov,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Radius', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: _fovRadius,
                              min: 50, max: 400,
                              activeColor: const Color(0xFFA855F7),
                              onChanged: _changeFovRadius,
                            ),
                          ),
                          Text('${_fovRadius.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  // === CROSSHAIR ===
                  _sectionCard(
                    title: 'CROSSHAIR',
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Aktifkan Crosshair', style: TextStyle(color: Colors.white, fontSize: 13)),
                          Switch(
                            value: _crosshairEnabled,
                            activeColor: const Color(0xFFA855F7),
                            onChanged: _toggleCrosshair,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Size', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: _crosshairSize,
                              min: 5, max: 60,
                              activeColor: const Color(0xFFA855F7),
                              onChanged: (v) {
                                setState(() => _crosshairSize = v);
                                OverlayBridge.sendCrosshair(
                                  enabled: _crosshairEnabled,
                                  style: _crosshairStyle,
                                  size: v,
                                );
                              },
                            ),
                          ),
                          Text('${_crosshairSize.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  // === SHIZUKU ===
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 14),
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

                  // === MENU CHEAT ===
                  ..._menus.keys.map((k) => Container(
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
                  )),
                ],
              ),
            ],
          ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(color: Color(0xFFA855F7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
