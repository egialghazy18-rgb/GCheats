import 'package:http/http.dart' as http;
import 'dart:convert';

class CheatService {
  static Future<void> sendToggle(String key, bool value) async {
    try {
      await http.post(
        Uri.parse('http://127.0.0.1:8080/api/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key, 'value': value}),
      );
    } catch (_) {}
  }
}
