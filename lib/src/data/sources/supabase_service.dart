import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // 1. Image Upload Logic
  Future<String> uploadImage(File imageFile) async {
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'scans/$fileName';

    await _supabase.storage.from('skin-scans').upload(path, imageFile);

    // Public URL lena taakay baad mein dikha sakein
    return _supabase.storage.from('skin-scans').getPublicUrl(path);
  }

  // 2. Data Save Logic
  Future<void> saveScanResult(Map<String, dynamic> scanData) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User logged in nahi hai!");

    await _supabase.from('scans').insert({
      ...scanData,
      'user_id': user.id,
    });
  }

  // 3. Fetch History Logic
  Future<List<Map<String, dynamic>>> fetchScanHistory() async {
    return await _supabase
        .from('scans')
        .select()
        .order('created_at', ascending: false);
  }
}