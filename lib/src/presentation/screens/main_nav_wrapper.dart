import 'dart:ui'; // Blur filter ke liye zaroori hai
import 'package:flutter/material.dart';
import '../../core/contants/app_colors.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({super.key});

  @override
  State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background ko poori app par apply karne ke liye Stack use kiya
      body: Stack(
        children: [
          // 1. AAPKI GOLDEN BUBBLES IMAGE (Image 1)
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_bg.jpg', // Is naam se image save karein
              fit: BoxFit.cover,
            ),
          ),

          // 2. BLUR LAYER (Taakay content saaf nazar aaye)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: Colors.white.withOpacity(0.4), // Light theme overlay
              ),
            ),
          ),

          // 3. ACTUAL SCREENS (IndexedStack)
          // Humne IndexedStack ko transparent banaya taakay peeche ka bg nazar aaye
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), // Glassmorphic navbar
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
          border: Border(top: BorderSide(color: AppColors.borderGrey.withOpacity(0.5), width: 0.5)),
        ),
        child: ClipRRect( // Navbar ko bhi glass effect dene ke liye
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.transparent, // Background transparent rakhein
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: AppColors.textSub,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  activeIcon: Icon(Icons.grid_view_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: "AI Chat",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.history_rounded),
                  label: "History",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}