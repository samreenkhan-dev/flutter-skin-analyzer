import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  // ✅ 1. metadata field define karein
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.metadata, // ✅ 2. metadata ko named parameter banayein
  });

  // Convert Supabase Auth User to our UserModel
  factory UserModel.fromSupabase(dynamic user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      // ✅ 3. metadata yahan se pass hoga
      metadata: user.userMetadata,
      fullName: user.userMetadata?['full_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  @override
  // ✅ 4. Props mein bhi metadata add karein taakay Equatable sahi kaam kare
  List<Object?> get props => [id, email, metadata, fullName, avatarUrl];
}