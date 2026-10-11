class ShizukuService {
  static bool _granted = false;

  static Future<bool> requestPermission() async {
    // Placeholder — integrasi riil pake platform channel
    // Cek apakah Shizuku manager terinstall & grant permission
    await Future.delayed(const Duration(milliseconds: 400));
    _granted = true;
    return _granted;
  }

  static bool get isGranted => _granted;
}
