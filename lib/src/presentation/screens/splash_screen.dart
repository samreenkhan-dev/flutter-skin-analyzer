import 'dart:ui';
import 'package:aiskinscan/src/presentation/screens/main_nav_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Background ke liye slow zoom animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Bohat slow aur smooth zoom
    )..forward();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _navigateToNext();
  }

  // SplashScreen.dart mein navigation logic update karein:

  void _navigateToNext() async {
    // 1. Minimum Splash Delay (4 seconds)
    await Future.delayed(const Duration(milliseconds: 4000));

    // Widget tree se screen remove hone par stop karein
    if (!mounted) return;

    // 2. Auth State Check karein
    final authBloc = context.read<AuthBloc>();
    Widget nextScreen;

    // 🛠️ IMPORTANT: Agar AuthBloc abhi tak check kar raha hai,
    // toh humein tab tak rukna chahiye jab tak result na aa jaye.
    if (authBloc.state is AuthInitial || authBloc.state is AuthLoading) {
      // Ham stream ka intezar karenge (Max 2 extra seconds)
      await for (final state in authBloc.stream.timeout(const Duration(seconds: 2))) {
        if (state is Authenticated || state is Unauthenticated) {
          break;
        }
      }
    }

    // 3. Final Decision based on State
    final currentState = authBloc.state;
    if (currentState is Authenticated) {
      nextScreen = const MainNavWrapper(); // Direct to Home/Main
    } else {
      nextScreen = const LoginScreen(); // Back to Login
    }

    // 4. Smooth Transition
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Luxury Fade Effect
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND (Magnified App BG)
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Positioned.fill(
                  child: Image.asset(
                    'assets/images/app_bg.jpg', // Same as other screens
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // 2. LUXURY BLUR & OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Halka blur texture dene ke liye
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. LOGO & BRANDING (Refined Layout)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist Logo Icon
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),

                // LUMINAIRE BRANDING
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 2),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Text(
                        "LUMINAIRE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "AI SKIN ANALYSIS",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. SUBTLE LOADING LINE (Elegant)
          Positioned(
            bottom: 80,
            left: 100,
            right: 100,
            child: Column(
              children: [
                Text(
                  "ESTABLISHED 2026",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 8,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 15),
                const LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  color: Colors.white,
                  minHeight: 1,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}