import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/contants/app_colors.dart';
import '../../logic/scanner_bloc/scanner_bloc.dart';
import '../../logic/scanner_bloc/scanner_event.dart';
import '../../logic/scanner_bloc/scanner_state.dart';
import '../widgets/skin_scanner_widget.dart';
import 'result_detail_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;

  Future<void> _handleImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 85);

    if (image != null) {
      // 1. Pehle image state mein set karein
      setState(() {
        _selectedImage = File(image.path);
      });

      // 2. Chota sa delay dein taakay UI image path catch kar sakay
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Phir analysis start karein
      if (mounted) {
        context.read<ScannerBloc>().add(StartAnalysisEvent(_selectedImage!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          // Navigating to Result Screen
          if (state is ScannerSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultDetailScreen(result: state.result),
              ),
            );
          }
          if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          // --- ✅ STEP 1: ANALYSIS UI ---
          if (state is ScannerLoading && _selectedImage != null) {
            return _buildScanningUI();
          }

          // --- STEP 2: CAMERA UI ---
          return Stack(
            children: [
              const Center(
                child: Text("Camera Preview Active", style: TextStyle(color: Colors.white)),
              ),

              // UI Frame
              Center(
                child: Container(
                  width: 260, height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: 15, left: 15, child: _buildCorner(0)),
                      Positioned(top: 15, right: 15, child: _buildCorner(1)),
                      Positioned(bottom: 15, left: 15, child: _buildCorner(2)),
                      Positioned(bottom: 15, right: 15, child: _buildCorner(3)),
                    ],
                  ),
                ),
              ),

              // Controls
              Positioned(
                bottom: 50, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(Icons.photo_library_outlined, () => _handleImage(context, ImageSource.gallery)),
                    _buildCaptureButton(() => _handleImage(context, ImageSource.camera)),
                    _buildIconButton(Icons.flash_off_rounded, () {}),
                  ],
                ),
              ),

              Positioned(
                top: 50, left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanningUI() {
    return Stack(
      children: [
        // ✅ IMAGE SHOULD SHOW HERE
        Positioned.fill(
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            // Fallback agar file read na ho
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
          ),
        ),

        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),

        const SkinScannerWidget(),

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "LUMINAIRE AI ANALYSIS",
                style: TextStyle(color: Colors.white, letterSpacing: 5, fontSize: 10),
              ),
              const SizedBox(height: 15),
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
            ],
          ),
        ),
      ],
    );
  }

  // Corner builders and buttons (Same as before)
  Widget _buildCorner(int angle) => Container(width: 20, height: 20, decoration: BoxDecoration(border: Border(top: angle < 2 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none, bottom: angle >= 2 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none, left: angle % 2 == 0 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none, right: angle % 2 != 0 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none)));
  Widget _buildIconButton(IconData icon, VoidCallback onTap) => IconButton(onPressed: onTap, icon: Icon(icon, color: Colors.white));
  Widget _buildCaptureButton(VoidCallback onTap) => GestureDetector(onTap: onTap, child: CircleAvatar(radius: 35, backgroundColor: Colors.white, child: CircleAvatar(radius: 32, backgroundColor: Colors.black, child: CircleAvatar(radius: 28, backgroundColor: Colors.white))));
}