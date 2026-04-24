import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../core/contants/app_colors.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import 'login_screen.dart';
import 'history_screen.dart'; // Add your screens here

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  bool _isUploading = false;

  // Image Picker & Upload Logic (Improved)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
      });

      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        // 1. Path: avatars folder ke andar user ki unique file
        final fileName = '${user.id}_profile.jpg';
        final path = 'avatars/$fileName';

        // 2. Storage mein upload (Upsert: true taakay purani file replace ho jaye)
        await Supabase.instance.client.storage.from('skin-scans').upload(
          path,
          _imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

        // 3. Public URL hasil karein
        final String publicUrl =
        Supabase.instance.client.storage.from('skin-scans').getPublicUrl(path);

        // 4. ✅ CORRECTED: Database Table Update (Using Upsert)
        // .update() ki jagah .upsert() use kiya hai taakay khali table mein row create ho jaye
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id, // Primary Key match karne ke liye zaroori hai
          'avatar_url': publicUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id'); // Agar ID pehle se hai toh sirf update karega

        // 5. Auth Metadata bhi update karein (Taakay Home Screen foran refresh ho)
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'avatar_url': publicUrl}),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Photo Updated Successfully! ✨")),
          );
        }
      } catch (e) {
        debugPrint("Full Upload Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userName = "GUEST USER";
    String userEmail = "Not Logged In";
    String? networkAvatar;

    if (authState is Authenticated) {
      userEmail = authState.user.email;
      userName = authState.user.metadata?['full_name'] ?? userEmail.split('@')[0].toUpperCase();
      networkAvatar = authState.user.metadata?['avatar_url'];
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // ✅ Correct Logout Navigation
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // PREMIUM BG
            // 1. PREMIUM BACKGROUND
            Positioned.fill(
              child: Image.asset('assets/images/app_bg.jpg', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.white.withOpacity(0.4)),
              ),
            ),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildEditableAvatar(networkAvatar),
                        const SizedBox(height: 20),
                        Text(userName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w200, letterSpacing: 1.5)),
                        Text(userEmail, style: const TextStyle(color: AppColors.textSub, fontSize: 13, letterSpacing: 0.5)),
                        const SizedBox(height: 40),

                        // SETTINGS SECTIONS
                        _buildProfileSection("Account Settings", [
                          _buildProfileOption(Icons.person_outline_rounded, "Personal Information", () {}),
                          _buildProfileOption(Icons.history_edu_rounded, "My Skin Journey", () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                          }),
                        ]),

                        const SizedBox(height: 25),

                        _buildProfileSection("App Experience", [
                          _buildProfileOption(Icons.notifications_none_rounded, "Notifications", () {
                            // Logic for notifications toggle
                          }),
                          _buildProfileOption(Icons.shield_moon_outlined, "Privacy & Data", () {}),
                          _buildProfileOption(Icons.help_outline_rounded, "Help & Support", () {}),
                        ]),

                        const SizedBox(height: 50),

                        // SIGN OUT BUTTON
                        _buildLogoutButton(context),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSliverAppBar() {
    return const SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text("MY ACCOUNT",
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w300, letterSpacing: 5, fontSize: 14)),
      ),
    );
  }

  Widget _buildEditableAvatar(String? networkUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey[100],
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (networkUrl != null ? NetworkImage(networkUrl) : null) as ImageProvider?,
            child: (networkUrl == null && _imageFile == null)
                ? const Icon(Icons.person_rounded, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        if (_isUploading)
          const CircleAvatar(radius: 65, backgroundColor: Colors.black26, child: CircularProgressIndicator(color: Colors.white)),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.textMain,
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 12),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub, letterSpacing: 2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white),
          ),
          child: Column(children: options),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Icon(icon, color: AppColors.textMain, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 60),
      ),
      child: const Text("SIGN OUT OF LUMINAIRE",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
    );
  }
}