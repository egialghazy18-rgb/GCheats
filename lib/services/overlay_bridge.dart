import 'package:flutter/services.dart';

class OverlayBridge {
  static const _channel = MethodChannel('nzwx/overlay_bridge');

  /// Kirim state FOV circle ke overlay (bubble window)
  static Future<void> sendFov({
    required bool enabled,
    required double radius,
  }) async {
    try {
      await _channel.invokeMethod('updateFov', {
        'enabled': enabled,
        'radius': radius,
      });
    } catch (_) {}
  }

  /// Kirim state game terdeteksi
  static Future<void> sendGameDetected(String? game) async {
    try {
      await _channel.invokeMethod('updateGame', {'game': game ?? ''});
    } catch (_) {}
  }

  /// Kirim state crosshair
  static Future<void> sendCrosshair({
    required bool enabled,
    required String style,
    required double size,
  }) async {
    try {
      await _channel.invokeMethod('updateCrosshair', {
        'enabled': enabled,
        'style': style,
        'size': size,
      });
    } catch (_) {}
  }
}
