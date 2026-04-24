import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/contants/app_colors.dart';
import '../../data/models/scan_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/action_button.dart';
import 'chat_screen.dart';

class ResultDetailScreen extends StatefulWidget {
  final ScanModel result;

  const ResultDetailScreen({super.key, required this.result});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  bool _isSaving = false;

  // --- LOGIC: SAVE TO SUPABASE ---
  Future<void> _saveToDiary() async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // 'user_scans' table mein data insert karna
      await Supabase.instance.client.from('user_scans').insert({
        'user_id': user.id,
        'condition_name': widget.result.conditionName,
        'description': widget.result.description,
        'image_url': widget.result.imageUrl,
        'confidence_score': widget.result.confidenceScore,
        'urgency_level': widget.result.urgencyLevel,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Analysis saved to your Skin Diary! ✨"),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _getUrgencyColor() {
    switch (widget.result.urgencyLevel) {
      case 'Red': return AppColors.errorRed;
      case 'Yellow': return AppColors.warningYellow;
      default: return AppColors.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("ANALYSIS REPORT",
            style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 3)),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50, right: -50,
            child: CircleAvatar(radius: 120, backgroundColor: urgencyColor.withOpacity(0.05)),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight + 60),

                // 1. IMAGE
                Center(
                  child: Container(
                    height: 320, width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: const Offset(0, 15))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(widget.result.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),

                      // 2. HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.result.conditionName.toUpperCase(),
                                    style: const TextStyle(color: AppColors.textMain, fontSize: 28, fontWeight: FontWeight.w200, letterSpacing: -1)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: urgencyColor, shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Text(widget.result.urgencyLevel == 'Red' ? "Action Required" : "Stable Condition",
                                        style: TextStyle(color: urgencyColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildScoreRing(urgencyColor),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 3. AI INSIGHTS
                      GlassCard(
                        opacity: 0.1,
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Text(widget.result.description,
                              style: const TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w300)),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 4. PRECAUTIONS
                      const Text("TREATMENT PLAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                      const SizedBox(height: 15),
                      ...widget.result.precautions.map((p) => _buildStepItem(p)).toList(),

                      const SizedBox(height: 40),

                      // 5. WORKING BUTTONS
                      ActionButton(
                        label: "START VIRTUAL CONSULTATION",
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        label: _isSaving ? "SAVING..." : "SAVE TO SKIN DIARY",
                        type: ButtonType.secondary,
                        onPressed: _isSaving ? null : _saveToDiary,
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRing(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 65, width: 65,
          child: CircularProgressIndicator(
            value: widget.result.confidenceScore,
            strokeWidth: 4,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Text("${(widget.result.confidenceScore * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStepItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}