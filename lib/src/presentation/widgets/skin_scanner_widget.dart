import 'package:flutter/material.dart';

class SkinScannerWidget extends StatefulWidget {
  const SkinScannerWidget({super.key});

  @override
  State<SkinScannerWidget> createState() => _SkinScannerWidgetState();
}

class _SkinScannerWidgetState extends State<SkinScannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Glowing Scanner Line
            Positioned(
              top: _controller.value * MediaQuery.of(context).size.height * 0.4,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0),
                          Colors.blueAccent,
                          Colors.blueAccent.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  // Barik Glow niche ki taraf
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blueAccent.withOpacity(0.2),
                          Colors.blueAccent.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}