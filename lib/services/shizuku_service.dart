import 'package:flutter/services.dart';

class ShizukuService {
  static const _channel = MethodChannel('nzwx/shizuku');
  static bool _granted = false;

  static Future<bool> isInstalled() async {
    try {
      return await _channel.invokeMethod<bool>('isInstalled') ?? false;
    } catch (_) { return false; }
  }

  static Future<bool> isRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isRunning') ?? false;
    } catch (_) { return false; }
  }

  static Future<bool> checkPermission() async {
    try {
      _granted = await _channel.invokeMethod<bool>('checkPermission') ?? false;
      return _granted;
    } catch (_) { return false; }
  }

  static Future<bool> requestPermission() async {
    try {
      _granted = await _channel.invokeMethod<bool>('requestPermission') ?? false;
      return _granted;
    } catch (_) { return false; }
  }

  static Future<int> getUid() async {
    try {
      return await _channel.invokeMethod<int>('getUid') ?? -1;
    } catch (_) { return -1; }
  }

  /// Execute shell command as shell (UID 2000) — butuh Shizuku permission.
  static Future<String> execShell(List<String> command) async {
    try {
      return await _channel.invokeMethod<String>('execShell', {
        'command': command,
      }) ?? '';
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  static bool get isGranted => _granted;
}
