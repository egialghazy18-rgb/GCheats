import 'package:flutter/services.dart';

class NativeHook {
  static const _channel = MethodChannel('nzwx/native_hook');

  static Future<String> getVersion() async {
    try {
      return await _channel.invokeMethod<String>('getVersion') ?? 'unknown';
    } catch (_) { return 'error'; }
  }

  static Future<int> findPid(String package) async {
    try {
      return await _channel.invokeMethod<int>('findPid', {'package': package}) ?? -1;
    } catch (_) { return -1; }
  }

  static Future<int> findModuleBase(int pid, String module) async {
    try {
      return await _channel.invokeMethod<int>('findModuleBase', {
        'pid': pid, 'module': module,
      }) ?? 0;
    } catch (_) { return 0; }
  }

  static Future<int> attach(int pid) async {
    try {
      return await _channel.invokeMethod<int>('attach', {'pid': pid}) ?? -1;
    } catch (_) { return -1; }
  }

  static Future<int> writeMemory(int pid, int addr, List<int> data) async {
    try {
      return await _channel.invokeMethod<int>('writeMemory', {
        'pid': pid, 'addr': addr, 'data': Uint8List.fromList(data),
      }) ?? -1;
    } catch (_) { return -1; }
  }
}
