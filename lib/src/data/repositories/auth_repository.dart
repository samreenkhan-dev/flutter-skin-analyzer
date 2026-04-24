import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Sign Up
  Future<UserModel> signUp({required String email, required String password}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception("Sign up failed.");
    return UserModel.fromSupabase(response.user!);
  }

  // 2. Login
  Future<UserModel> login({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception("Login failed.");
    return UserModel.fromSupabase(response.user!);
  }

  // 3. Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 4. Get Current User
  UserModel? get currentUser {
    final user = _supabase.auth.currentUser;
    return user != null ? UserModel.fromSupabase(user) : null;
  }
}