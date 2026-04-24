import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    // 1. API Key ko load karein
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';

    // 2. Model ko aik hi baar initialize karein
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
    );
  }

  // --- AI Chat Logic ---
  Future<String> getChatResponse(String prompt) async {
    try {
      // System instruction ke saath content prepare karein
      final content = [
        Content.text("You are a professional DermAI skin consultant. Answer the following user query about skin health: $prompt")
      ];

      // Constructor mein banaya gaya _model hi use karein
      final response = await _model.generateContent(content);
      return response.text ?? "I couldn't analyze that. Please try again.";
    } catch (e) {
      return "Error: $e";
    }
  }

  // --- Image Analysis Logic ---
  Future<Map<String, dynamic>> analyzeSkinImage(File imageFile) async {
    int maxRetries = 3; // Maximum 3 baar koshish karega
    int retryCount = 0;
    int sleepDuration = 2; // Pehle retry se pehle 2 seconds ka wait

    while (retryCount < maxRetries) {
      try {
        final imageBytes = await imageFile.readAsBytes();

        final prompt = TextPart("""
        Analyze this skin image for dermatological conditions. 
        Provide the result strictly in JSON format with these keys:
        - condition_name: (Name of the condition)
        - confidence_score: (Match percentage as a decimal, e.g., 0.95)
        - description: (Brief explanation of the condition)
        - precautions: (A list of 3 short advice strings)
        - urgency_level: (Must be either 'Green', 'Yellow', or 'Red')
      """);

        final content = [
          Content.multi([
            prompt,
            DataPart('image/jpeg', imageBytes),
          ])
        ];

        final response = await _model.generateContent(content);
        final text = response.text;

        if (text != null) {
          final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(cleanJson);
        } else {
          throw Exception("The AI did not provide a response.");
        }
      } catch (e) {
        // ✅ 503 Error Check
        if (e.toString().contains('503')) {
          retryCount++;
          if (retryCount < maxRetries) {
            print("Server Busy (503). Attempt $retryCount failed. Retrying in $sleepDuration seconds...");
            await Future.delayed(Duration(seconds: sleepDuration));
            sleepDuration *= 2; // Agli baar intezar double (2s -> 4s)
            continue; // Dubara loop chalayein
          }
        }

        // Agar retry khatam ho jayein ya koi aur error ho
        throw Exception("Gemini Error: $e");
      }
    }
    throw Exception("Server is currently overloaded. Please try again later.");
  }
}