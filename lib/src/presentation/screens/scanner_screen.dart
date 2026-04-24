import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/scanner_bloc/scanner_bloc.dart';
import '../../logic/scanner_bloc/scanner_event.dart';
import '../../logic/scanner_bloc/scanner_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/skin_scanner_widget.dart'; // ✅ Import laser line widget
import 'result_detail_screen.dart'; // Result screen import

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _capturedFile; // Image store karne ke liye variable

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _capturedFile = File(pickedFile.path); // 1. Image save karein
      });
      // 2. Analysis start karein
      context.read<ScannerBloc>().add(StartAnalysisEvent(_capturedFile!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerSuccess) {
            // ✅ Success par Result Screen par jayein
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ResultDetailScreen(result: state.result))
            );
          }
        },
        builder: (context, state) {
          // --- ✅ STEP 1: SCANNING UI (With your custom widget) ---
          if (state is ScannerLoading && _capturedFile != null) {
            return Stack(
              children: [
                // Peeche wohi image jo select ki gayi
                Positioned.fill(
                  child: Image.file(_capturedFile!, fit: BoxFit.cover),
                ),
                // Halka dark overlay
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),

                // 🔥 AAPKA CUSTOM LASER WIDGET
                const SkinScannerWidget(),

                // Loading Text
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 150),
                      Text(
                        "AI ANALYSIS IN PROGRESS",
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Checking skin patterns...", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            );
          }

          // --- STEP 2: INITIAL UI (Camera/Gallery Selection) ---
          return Stack(
            children: [
              // Background Aesthetic Circles
              Positioned(
                top: -100,
                right: -100,
                child: CircleAvatar(radius: 150, backgroundColor: Colors.blue.withOpacity(0.1)),
              ),

              Center(
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.blueAccent, size: 50),
                        const SizedBox(height: 20),
                        const Text(
                          "Smart Skin Scan",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: 1),
                        ),
                        const SizedBox(height: 30),

                        // Open Camera Button
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(context, ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text("LAUNCH CAMERA"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Gallery Button
                        TextButton(
                          onPressed: () => _pickImage(context, ImageSource.gallery),
                          child: const Text("Select from Gallery", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Back Button
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}