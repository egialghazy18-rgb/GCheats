class ShizukuService {
  static bool _granted = false;
  static Future<bool> requestPermission() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _granted = true;
    return _granted;
  }
  static bool get isGranted => _granted;
}
