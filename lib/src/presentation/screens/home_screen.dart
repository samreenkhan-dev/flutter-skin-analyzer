import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/contants/app_colors.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import 'camera_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auth State se User ki info nikalna
    final authState = context.watch<AuthBloc>().state;
    String firstName = "GUEST";
    String? avatarUrl;

    if (authState is Authenticated) {
      firstName = authState.user.email.split('@')[0].split('.')[0];
      // Pehla letter capital karne ke liye
      firstName = firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
      avatarUrl = authState.user.metadata?['avatar_url'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Premium Soft White
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. PROFILE GREETING SECTION (Top) ---
              _buildTopProfileSection(context, firstName, avatarUrl),

              // --- 2. HERO CARD SECTION (Pinterest Style) ---
              _buildHeroCard('assets/images/bg_texture_1.jpg'),

              const SizedBox(height: 30),

              // --- 3. QUICK ACTION NODES ---
              _buildQuickActionNodes(context),

              const SizedBox(height: 40),

              // --- 4. EXPERT DIAGNOSTICS ---
              _buildSectionHeader("Expert Diagnostics"),
              _buildConcernsSection(),

              const SizedBox(height: 40),

              // --- 5. RECOMMENDED PRODUCTS ---
              _buildSectionHeader("Curated for Your Skin"),
              _buildProductsSection(),

              const SizedBox(height: 120), // Bottom space for FAB
            ],
          ),
        ),
      ),

      // AI Scan Floating Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildScanButton(context),
    );
  }

  // --- UI HELPER COMPONENTS ---

  // 1. Top Profile Greeting
  Widget _buildTopProfileSection(BuildContext context, String name, String? avatar) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi $name,",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textMain, letterSpacing: -1)),
              Text("Transform Your Skin's Health",
                  style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[200],
                backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
                child: (avatar == null || avatar.isEmpty) ? const Icon(Icons.person, color: Colors.grey) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Pinterest-Style Hero Card
  Widget _buildHeroCard(String path) {
    return Container(
      height: 250, // Increased height for a better portrait view
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Very soft shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // 1. Background Image (Portrait of Girl)
            Positioned.fill(
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter, // Focus on the face
              ),
            ),

            // 2. Subtle Soft Gradient Overlay (Light overlay for text readability)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, // Gradient comes from bottom
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.5), // Subtle dark at bottom
                      Colors.black.withOpacity(0.1),
                      Colors.transparent, // Completely clear at top/face
                    ],
                    stops: const [0.0, 0.4, 0.8],
                  ),
                ),
              ),
            ),

            // 3. Elegant Text Content (No Button)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Position text at bottom
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ELEVATE YOUR GLOW",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3, // Wide spacing for luxury look
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Discover the essence\nof flawless skin.",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w200, // Very light, expensive feel
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),

                  // ✅ Elegant CTA Text instead of Button

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Quick Action Nodes
  Widget _buildQuickActionNodes(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionItem(context, Icons.auto_awesome_rounded, "AI Chat", Colors.blueAccent, const ChatScreen()),
          _buildActionItem(context, Icons.history_rounded, "Journey", Colors.orangeAccent, const HistoryScreen()),
          _buildActionItem(context, Icons.collections_bookmark_rounded, "Diary", Colors.purpleAccent, null),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, Widget? page) {
    return GestureDetector(
      onTap: () => page != null ? Navigator.push(context, MaterialPageRoute(builder: (_) => page)) : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        ],
      ),
    );
  }

  // 4. Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  // 5. Concerns Section
  Widget _buildConcernsSection() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildConcernCircle("Acne", "assets/images/acne_ref.jpg"),
          _buildConcernCircle("Dryness", "assets/images/dryness_ref.jpg"),
          _buildConcernCircle("Rosacea", "assets/images/rosacea_ref.jpg"),
        ],
      ),
    );
  }

  Widget _buildConcernCircle(String label, String path) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(radius: 35, backgroundImage: AssetImage(path)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 6. Products Section
  Widget _buildProductsSection() {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildProductCard("Face Wash", "assets/images/product_1.jpg", "\$20.00"),
          _buildProductCard("Glow Serum", "assets/images/product_2.jpg", "\$48.00"),
          _buildProductCard("Night Repair", "assets/images/product_3.jpg", "\$55.00"),

        ],
      ),
    );
  }

  Widget _buildProductCard(String name, String path, String price) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), child: Image.asset(path, fit: BoxFit.cover, width: double.infinity))),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(price, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 7. Scan Button
  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      height: 65,
      width: 220,
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
        backgroundColor: AppColors.textMain,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        icon: const Icon(Icons.center_focus_strong_rounded, color: Colors.white),
        label: const Text("START AI SCAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}