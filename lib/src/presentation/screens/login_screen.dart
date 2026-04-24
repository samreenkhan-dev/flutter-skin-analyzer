import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/contants/app_colors.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../widgets/glass_card.dart';
import 'signup_screen.dart';
import 'main_nav_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For validation
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND
          Positioned.fill(
            child: Image.asset('assets/images/app_bg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.5)),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey, // Form key implementation
                child: Column(
                  children: [
                    // LOGO Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, size: 45, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(height: 24),

                    const Text("Welcome Back",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w200, color: AppColors.textMain, letterSpacing: 1.5)),
                    const Text("Log in to continue your glow journey",
                        style: TextStyle(color: AppColors.textSub, fontSize: 13, letterSpacing: 0.5)),

                    const SizedBox(height: 40),

                    // LOGIN FORM (Glass Card)
                    GlassCard(
                      opacity: 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              hint: "Email Address",
                              icon: Icons.alternate_email_rounded,
                              validator: (value) {
                                if (value == null || !value.contains('@')) return "Enter a valid email";
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              controller: _passwordController,
                              hint: "Password",
                              icon: Icons.lock_outline_rounded,
                              isPassword: _obscureText,
                              suffix: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) return "Min 6 characters required";
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // --- AUTH BLOC CONSUMER ---
                            BlocConsumer<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state is Authenticated) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavWrapper()));
                                }
                                if (state is AuthError) {
                                  // Handling the specific Supabase Confirmation Error
                                  String errorMsg = state.message;
                                  if (errorMsg.contains("Email not confirmed")) {
                                    errorMsg = "⚠️ Please verify your email or disable confirmation in Supabase.";
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMsg),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                if (state is AuthLoading) return const CircularProgressIndicator(color: AppColors.textMain);

                                return ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        LoginRequested(
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
                                  child: const Text("Login",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // SIGNUP REDIRECT
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppColors.textSub, fontSize: 14),
                          children: [
                            TextSpan(text: "New here? "),
                            TextSpan(text: "Create an Account", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField( // Changed to TextFormField for validation
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: AppColors.textMain),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.6), size: 20),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSub, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}