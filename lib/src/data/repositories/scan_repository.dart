import 'dart:io';
import '../models/scan_model.dart';
import '../sources/gemini_service.dart';
import '../sources/supabase_service.dart';

class ScanRepository {
  final GeminiService _geminiService;
  final SupabaseService _supabaseService;

  ScanRepository(this._geminiService, this._supabaseService);

  /// This method performs the full workflow:
  /// 1. Uploads image to Storage
  /// 2. Gets AI Analysis from Gemini
  /// 3. Saves everything to the Database
  Future<ScanModel> processNewScan(File imageFile) async {
    try {
      // Step 1: Upload Image
      final imageUrl = await _supabaseService.uploadImage(imageFile);

      // Step 2: Get AI Result
      final aiRawData = await _geminiService.analyzeSkinImage(imageFile);

      // Step 3: Combine data
      final completeData = {
        ...aiRawData,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Step 4: Save to DB
      await _supabaseService.saveScanResult(completeData);

      // Step 5: Return as Model
      return ScanModel.fromJson(completeData);
    } catch (e) {
      throw Exception("Scan Repository Error: $e");
    }
  }

  /// Fetches the user's scan history
  Future<List<ScanModel>> getHistory() async {
    final List<Map<String, dynamic>> data = await _supabaseService.fetchScanHistory();
    return data.map((json) => ScanModel.fromJson(json)).toList();
  }
}