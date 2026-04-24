import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/contants/app_colors.dart';
import '../../logic/history_bloc/history_bloc.dart';
import '../../logic/history_bloc/history_event.dart';
import '../../logic/history_bloc/history_state.dart';
import 'result_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(FetchHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Soft off-white to match Home
      appBar: _buildSimpleLuxuryAppBar(context),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMain),
            );
          }

          if (state is HistoryEmpty) {
            return _buildEmptyState();
          }

          if (state is HistoryLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: state.scans.length,
              itemBuilder: (context, index) {
                return _buildHistoryCard(context, state.scans[index]);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // --- UI COMPONENTS ---

  // 1. Clean AppBar matching the greeting style
  PreferredSizeWidget _buildSimpleLuxuryAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9FB),
      elevation: 0,
      centerTitle: true,
      // ✅ Back button remove karne ke liye ye line add karein
      automaticallyImplyLeading: false,
      title: const Text(
        "Skin Journey",
        style: TextStyle(
          color: AppColors.textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  // 2. Modern History Card (Pinterest Style)
  Widget _buildHistoryCard(BuildContext context, dynamic scan) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultDetailScreen(result: scan))
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Image Section
              Hero(
                tag: scan.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(25)),
                  child: Image.network(
                    scan.imageUrl,
                    width: 110,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 110,
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM dd').format(scan.createdAt),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        scan.conditionName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Tag
                      Row(
                        children: [
                          _buildUrgencyIndicator(scan.urgencyLevel),
                          const SizedBox(width: 8),
                          Text(
                            "${(scan.confidenceScore * 100).toInt()}% Match",
                            style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Small Dot for Urgency
  Widget _buildUrgencyIndicator(String level) {
    Color color;
    switch (level.toLowerCase()) {
      case 'red': color = Colors.redAccent; break;
      case 'yellow': color = Colors.orangeAccent; break;
      default: color = Colors.greenAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_history.png', width: 150, errorBuilder: (c,e,s) => Icon(Icons.history, size: 80, color: Colors.grey[200])),
          const SizedBox(height: 20),
          const Text("Your Journey Starts Here",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 8),
          const Text("Perform your first AI scan to see history.",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}