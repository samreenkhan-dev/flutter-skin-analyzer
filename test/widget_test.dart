import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aiskinscan/main.dart';
import 'package:aiskinscan/src/data/repositories/auth_repository.dart';
import 'package:aiskinscan/src/data/repositories/scan_repository.dart';
import 'package:aiskinscan/src/data/sources/gemini_service.dart';
import 'package:aiskinscan/src/data/sources/supabase_service.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // 1. Initialize Services & Repositories
    final geminiService = GeminiService(); // ✅ Naya instance banayein
    final authRepository = AuthRepository();

    // ScanRepository ko GeminiService aur SupabaseService dono chahiye
    final scanRepository = ScanRepository(geminiService, SupabaseService());

    // 2. Build our app and trigger a frame.
    // ✅ FIX: Ab 'geminiService' argument bhi pass karein
    await tester.pumpWidget(DermAI(
      authRepository: authRepository,
      scanRepository: scanRepository,
      geminiService: geminiService, // 👈 Ye argument missing tha
    ));

    // Check karein ke Splash Screen par LUMINAIRE ya DermAI nazar aa raha hai
    // Humne Splash ka naam badal kar LUMINAIRE rakha tha, isliye find.text update kiya
    expect(find.textContaining('LUMINAIRE'), findsWidgets);
  });
}