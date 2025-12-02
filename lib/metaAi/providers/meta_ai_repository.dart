// lib/metaAi/providers/meta_ai_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MetaAIRepository {
  // TODO: paste your real Gemini key here
  final String apiKey = "YOUR_GEMINI_KEY_HERE";

  Future<String> getAIResponse(String prompt) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "⚠️ Gemini error (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "❌ Network or parsing error: $e";
    }
  }
}
