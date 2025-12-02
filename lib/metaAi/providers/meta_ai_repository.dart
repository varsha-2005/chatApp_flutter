// lib/metaAi/providers/meta_ai_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MetaAIRepository {
  // TODO: paste your real Gemini key here
  final String apiKey = "AIzaSyCGLWzSxEnBLvSWy4AnqmF7fEYb5ts_aP8";

  Future<String> getAIResponse(String prompt) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        debugPrint("MetaAIRepository getAIResponse failed: ${response.body}");
        return "⚠️ Gemini error (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      debugPrint("MetaAIRepository getAIResponse error: $e");
      return "❌ Network or parsing error: $e";
    }
  }
}
