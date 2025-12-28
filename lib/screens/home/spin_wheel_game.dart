import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class SpinWheelGame extends StatefulWidget {
  final Function(double) onWin;
  
  const SpinWheelGame({super.key, required this.onWin});

  @override
  State<SpinWheelGame> createState() => _SpinWheelGameState();
}

class _SpinWheelGameState extends State<SpinWheelGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ConfettiController _confettiController;
  
  bool _isSpinning = false;
  double _finalAngle = 0;
  int _selectedPrizeIndex = 0;
  int? _userSelectedNumber; 
  int _attempts = 999; 

  // 0-9 Numbers
  final List<int> _prizes = List.generate(10, (index) => index);
  
  // Minimalist Premium Palette: Alternating Dark Grays and Obsidian
  final List<Color> _segmentColors = [
    const Color(0xFF2A2A2A), // Lighter Grey
    const Color(0xFF151515), // Deep Obsidian
    const Color(0xFF2A2A2A),
    const Color(0xFF151515),
    const Color(0xFF2A2A2A),
    const Color(0xFF151515),
    const Color(0xFF2A2A2A),
    const Color(0xFF151515),
    const Color(0xFF2A2A2A),
    const Color(0xFF151515),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 8), 
        vsync: this
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onSpinPressed() {
    if (_isSpinning) return;
    _showNumberSelectionDialog();
  }

  void _showNumberSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.white.withOpacity(0.1))),
          title: Text(
            "CHOOSE A NUMBER",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.normal, letterSpacing: 3, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _startSpin(index);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.vividGold.withOpacity(0.3), width: 1),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: Center(
                      child: Text(
                        "$index",
                        style: GoogleFonts.outfit(
                          color: AppTheme.vividGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _startSpin(int selectedNumber) {
    setState(() {
      _isSpinning = true;
      _userSelectedNumber = selectedNumber;
    });

    final random = math.Random();
    _selectedPrizeIndex = random.nextInt(_prizes.length);
    final extraRotations = 8 + random.nextInt(4); 
    final segmentAngle = 2 * math.pi / _prizes.length;
    _finalAngle = (extraRotations * 2 * math.pi) + ((_prizes.length - _selectedPrizeIndex) * segmentAngle);

    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _isSpinning = false;
      });
      _checkResult();
    });
  }

  void _checkResult() {
    if (_selectedPrizeIndex == _userSelectedNumber) {
      _confettiController.play();
      _showWinDialog();
    } else {
      _showLossDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: AppTheme.goldStart, width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: AppTheme.vividGold, size: 60).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              "WINNER",
              style: GoogleFonts.outfit(color: AppTheme.vividGold, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 4),
            ),
            const SizedBox(height: 12),
            Text(
              "₹100",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: AppTheme.goldGradient,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onWin(100.0);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text("COLLECT REWARD", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLossDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        contentPadding: const EdgeInsets.all(30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("SPIN COMPLETE", style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12, letterSpacing: 2)),
             const SizedBox(height: 20),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Column(
                   children: [
                     Text("RESULT", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                     const SizedBox(height: 4),
                     Text("$_selectedPrizeIndex", style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                   ],
                 ),
                 Container(width: 1, height: 40, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 24)),
                 Column(
                   children: [
                     Text("YOUR PICK", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                     const SizedBox(height: 4),
                     Text("$_userSelectedNumber", style: GoogleFonts.outfit(color: AppTheme.vividGold, fontSize: 28, fontWeight: FontWeight.bold)),
                   ],
                 ),
               ],
             ),
             const SizedBox(height: 30),
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: Text("TRY AGAIN", style: GoogleFonts.outfit(color: Colors.white, letterSpacing: 1)),
             ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("FORTUNE SPIN", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, letterSpacing: 3, fontSize: 14, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Wheel Section
               SizedBox(
                 height: 360,
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     // 1. Shadow Base
                     Container(
                       width: 320, height: 320,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, spreadRadius: -5),
                         ],
                       ),
                     ),
                     
                     // 2. The Clean Wheel
                     AnimatedBuilder(
                       animation: _animation,
                       builder: (context, child) {
                         return Transform.rotate(
                           angle: _animation.value * _finalAngle,
                           child: child,
                           alignment: Alignment.center,
                         );
                       },
                       child: SizedBox(
                         width: 300, height: 300,
                         child: CustomPaint(
                           painter: MinimalWheelPainter(
                             segments: 10,
                             colors: _segmentColors,
                           ),
                         ),
                       ),
                     ),
                     
                     // 3. Minimalist Hub
                     Container(
                       width: 60, height: 60,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: const Color(0xFF151515),
                         border: Border.all(color: AppTheme.vividGold, width: 1.5),
                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                       ),
                       child: const Center(
                          child: Icon(Icons.circle, color: AppTheme.goldStart, size: 8),
                       ),
                     ),
                     
                     // 4. Clean Geometric Pointer
                     Positioned(
                       top: 0,
                       child: Column(
                         children: [
                           Container(
                             width: 14, height: 40,
                             decoration: BoxDecoration(
                               color: AppTheme.vividGold,
                               borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
               
               const SizedBox(height: 60),
               
               // Clean Action Button
               AnimatedOpacity(
                 opacity: _isSpinning ? 0.5 : 1.0,
                 duration: const Duration(milliseconds: 200),
                 child: GestureDetector(
                   onTap: _isSpinning ? null : _onSpinPressed,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                     decoration: BoxDecoration(
                       border: Border.all(color: AppTheme.vividGold.withOpacity(0.3), width: 1),
                       borderRadius: BorderRadius.circular(40),
                       color: Colors.white.withOpacity(0.05),
                     ),
                     child: Text(
                       _isSpinning ? "SPINNING..." : "SPIN NOW",
                       style: GoogleFonts.outfit(
                         color: AppTheme.vividGold,
                         fontWeight: FontWeight.w600,
                         fontSize: 14,
                         letterSpacing: 3,
                       ),
                     ),
                   ),
                 ),
               ),
               
               // Confetti Overlay
               Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2,
                  maxBlastForce: 20,
                  minBlastForce: 10,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  colors: const [AppTheme.vividGold, Colors.white],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MinimalWheelPainter extends CustomPainter {
  final int segments;
  final List<Color> colors;

  MinimalWheelPainter({required this.segments, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / segments;

    final paint = Paint()..style = PaintingStyle.fill;
    final dividerPaint = Paint()
      ..color = const Color(0xFF151515) // Dark divider matching hub
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; 

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < segments; i++) {
      paint.color = colors[i % colors.length];
      
      // Draw segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle - math.pi / 2,
        segmentAngle,
        true,
        paint,
      );
      
      // Draw Dark Divider
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle - math.pi / 2,
        segmentAngle,
        true,
        dividerPaint,
      );

      // Draw Number
      final angle = (i * segmentAngle) + (segmentAngle / 2) - math.pi / 2;
      final offset = Offset(
        center.dx + (radius * 0.8) * math.cos(angle),
        center.dy + (radius * 0.8) * math.sin(angle),
      );
      
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle + math.pi / 2); 
      
      textPainter.text = TextSpan(
        text: "$i",
        style: GoogleFonts.outfit(
          color: Colors.white.withOpacity(0.9),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      
      canvas.restore();
    }
    
    // Outer Clean Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppTheme.vividGold.withOpacity(0.2);
      
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
