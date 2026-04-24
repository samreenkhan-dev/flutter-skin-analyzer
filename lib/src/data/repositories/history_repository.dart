// history_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/scan_model.dart';

class HistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<ScanModel>> fetchHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    // Table name aur column names check karein (user_id se filter lazmi hai)
    final response = await _supabase
        .from('user_scans') // Aapke table ka naam
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ScanModel.fromJson(json)).toList();
  }
}