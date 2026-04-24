import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/contants/app_colors.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✅ Password visibility control karne ke liye variable
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/app_bg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.6)),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 50, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 24),

                  const Text("Begin Your Radiance",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w200, color: AppColors.textMain, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  const Text("Create an account to start your glow journey",
                      style: TextStyle(color: AppColors.textSub, letterSpacing: 0.5)),
                  const SizedBox(height: 40),

                  GlassCard(
                    opacity: 0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            hint: "Full Name",
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _emailController,
                            hint: "Email Address",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 20),

                          // ✅ Password Field with Toggle
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline_rounded,
                            isPassword: _isPasswordObscured, // Variable used here
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSub,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 30),

                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is Authenticated) {
                                // Signup ke baad agar dashboard se email confirmation OFF hai toh direct login
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                              }
                              if (state is AuthError) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                              }
                            },
                            builder: (context, state) {
                              if (state is AuthLoading) return const CircularProgressIndicator(color: AppColors.textMain);

                              return ElevatedButton(
                                onPressed: () {
                                  if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                                    context.read<AuthBloc>().add(
                                      SignUpRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textMain,
                                  minimumSize: const Size(double.infinity, 60),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                child: const Text("CREATE ACCOUNT",
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.textSub, fontSize: 14),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(text: "Login", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE TEXT FIELD WITH OPTIONAL SUFFIX ICON ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon, // Added suffixIcon
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Logic implemented here
        style: const TextStyle(color: AppColors.textMain),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          suffixIcon: suffixIcon, // Suffix icon (Eye icon)
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSub, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}