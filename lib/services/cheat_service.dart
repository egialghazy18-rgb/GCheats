import 'package:http/http.dart' as http;
import 'dart:convert';

class CheatService {
  static const String _endpoint = 'http://127.0.0.1:8080/api/toggle';

  static Future<void> sendToggle(String key, bool value) async {
    try {
      await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key, 'value': value}),
      );
    } catch (_) {
      // Silent — backend lokal belum tentu hidup
    }
  }
}
