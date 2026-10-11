import 'dart:async';
import 'package:flutter/services.dart';

class GameDetector {
  static const _channel = MethodChannel('nzwx/game_detector');

  // Package name game yang dideteksi
  static const Map<String, String> gamePackages = {
    'com.dts.freefireth': 'Free Fire',
    'com.dts.freefiremax': 'Free Fire MAX',
    'com.mobile.legends': 'Mobile Legends',
    'com.tencent.ig': 'PUBG Mobile',
    'com.pubg.imobile': 'BGMI',
    'com.garena.game.codm': 'COD Mobile',
    'com.activision.callofduty.shooter': 'CODM',
    'com.mojang.minecraftpe': 'Minecraft',
    'com.riotgames.league.wildrift': 'Wild Rift',
  };

  static Timer? _timer;
  static String? _currentGame;

  /// Mulai polling cek foreground app tiap 1 detik
  static void startWatching(Function(String? gameName) onChanged) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final detected = await _getForegroundPackage();
      final gameName = gamePackages[detected];
      if (gameName != _currentGame) {
        _currentGame = gameName;
        onChanged(gameName);
      }
    });
  }

  static void stopWatching() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<String?> _getForegroundPackage() async {
    try {
      final result = await _channel.invokeMethod<String>('getForegroundPackage');
      return result;
    } catch (_) {
      return null;
    }
  }
}
