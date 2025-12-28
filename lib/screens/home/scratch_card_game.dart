import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import 'dart:ui' as ui;

class ScratchCardGame extends StatefulWidget {
  final Function(double) onWin;
  
  const ScratchCardGame({super.key, required this.onWin});

  @override
  State<ScratchCardGame> createState() => _ScratchCardGameState();
}

class _ScratchCardGameState extends State<ScratchCardGame> {
  late ConfettiController _confettiController;
  
  // Game State
  int? _selectedCardIndex; // 0, 1, 2
  bool _isScratching = false;
  bool _isRevealed = false;
  double _scratchProgress = 0.0;
  
  // The cards for the current round
  late List<String> _cards;
  String _revealedSymbol = "";

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _startNewRound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _selectedCardIndex = null;
      _isScratching = false;
      _isRevealed = false;
      _scratchProgress = 0.0;
      
      // Shuffle the 3 symbols
      _cards = ["Flag", "Rabbit", "Turtle"];
      _cards.shuffle();
    });
  }

  void _selectCard(int index) {
    setState(() {
      _selectedCardIndex = index;
      _revealedSymbol = _cards[index];
      _isScratching = true;
    });
  }

  void _onScratchComplete() {
    if (_isRevealed) return;
    
    setState(() {
      _isRevealed = true;
    });

    if (_revealedSymbol == "Flag") {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 1), () {
        _showWinDialog();
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        _showLossDialog();
      });
    }
  }
  
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppTheme.vividGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag, size: 60, color: AppTheme.successGreen).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text("YOU FOUND THE FLAG!", style: GoogleFonts.outfit(color: AppTheme.successGreen, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text("₹100", style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onWin(100);
                Navigator.pop(context); // Go back to Game Center
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldStart, foregroundColor: Colors.black),
              child: const Text("CLAIM REWARD"),
            )
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _revealedSymbol == "Rabbit" ? Icons.pets : Icons.bug_report, // Rabbit or Turtle icon
              size: 50, 
              color: Colors.white54
            ),
            const SizedBox(height: 20),
            Text("OOPS!", style: GoogleFonts.outfit(color: AppTheme.errorRed, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Text(
              "You found a $_revealedSymbol.\nFind the Flag to win!", 
              style: GoogleFonts.outfit(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewRound();
              },
              child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white)),
            )
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
        title: Text("SCRATCH & WIN", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [Color(0xFF222222), Colors.black],
                radius: 1.2,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Text
                if (!_isScratching)
                  Column(
                    children: [
                      Text(
                        "PICK A CARD",
                        style: GoogleFonts.outfit(color: AppTheme.vividGold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        "Select one lucky card to scratch",
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                
                const Spacer(),
                
                // Card Area
                SizedBox(
                  height: 400,
                  child: Center(
                    child: _isScratching 
                      ? _buildScratchArea() // The single large card
                      : _buildCardSelection(), // The 3 cards
                  ),
                ),
                
                const Spacer(),
                
                // Footer
                if (_isScratching)
                  TextButton.icon(
                    onPressed: _startNewRound,
                    icon: const Icon(Icons.refresh, color: Colors.white54),
                    label: Text("PICK DIFFERENT CARD", style: GoogleFonts.outfit(color: Colors.white54)),
                  ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 20,
              minBlastForce: 10,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [AppTheme.vividGold, Colors.white, AppTheme.neonGreen],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return GestureDetector(
          onTap: () => _selectCard(index),
          child: Container(
            width: 100,
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppTheme.goldGradient,
              boxShadow: [
                BoxShadow(color: AppTheme.goldStart.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Stack(
              children: [
                // Pattern
                Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: PatternPainter(),
                    size: const Size(100, 150),
                  ),
                ),
                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.diamond_outlined, color: Colors.black54, size: 30),
                  ),
                ),
              ],
            ),
          ).animate().scale(delay: (index * 200).ms, duration: 400.ms, curve: Curves.easeOutBack)
           .animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -10, duration: 2.seconds, delay: (index * 300).ms),
        );
      }),
    );
  }

  Widget _buildScratchArea() {
    // This uses a custom Scratcher implementation since we don't have the package
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRevealed ? "RESULT" : "SCRATCH NOW",
            style: GoogleFonts.outfit(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // 1. The Result (Bottom Layer)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _revealedSymbol == "Flag" 
                                ? Icons.flag 
                                : (_revealedSymbol == "Rabbit" ? Icons.pets : Icons.bug_report),
                            color: _revealedSymbol == "Flag" ? AppTheme.successGreen : AppTheme.errorRed,
                            size: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _revealedSymbol.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.black87,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (_revealedSymbol == "Flag")
                           Text("WINNER!", style: GoogleFonts.outfit(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  // 2. The Scratch Layer (Top Layer)
                  // We implement this using a simplified gesture detector drawing lines that clear the canvas?
                  // No, "clear" blend mode is hard without a specialized package or advanced render object.
                  // BETTER APPROACH: Use a "Scratcher" logic where we draw clear lines on a PictureRecorder or Image.
                  // Simpler for this environment: Use a Grid of opacity blocks that disappear on hover?
                  // Or just implement a basic CustomPaint that tracks points.
                  
                  if (!_isRevealed)
                    _ManualScratcher(
                      onScratch: (percentage) {
                        setState(() {
                          _scratchProgress = percentage;
                        });
                        if (percentage > 50) {
                          _onScratchComplete();
                        }
                      },
                      cover: Container(
                         decoration: BoxDecoration(
                           gradient: AppTheme.goldGradient,
                         ),
                         child: Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Icon(Icons.touch_app, color: Colors.black26, size: 50),
                               Text("RUB TO REVEAL", style: GoogleFonts.outfit(color: Colors.black26, fontWeight: FontWeight.bold)),
                             ],
                           ),
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
}

// A simple minimalist pattern for card backs
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
      
    for(var i=0; i<size.width; i+=10) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(0, i.toDouble()), paint);
    }
  }
  @override
  bool shouldRepaint(old) => false;
}

// CUSTOM SCRATCHER IMPLEMENTATION
class _ManualScratcher extends StatefulWidget {
  final Widget cover;
  final Function(double) onScratch;

  const _ManualScratcher({required this.cover, required this.onScratch});

  @override
  State<_ManualScratcher> createState() => _ManualScratcherState();
}

class _ManualScratcherState extends State<_ManualScratcher> {
  final List<Offset> _points = [];
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localPosition = box.globalToLocal(details.globalPosition);
        
        setState(() {
          _points.add(localPosition);
        });
        
        // Estimate progress simply by number of points vs area approx
        // Not perfect but works for "rub a bit then reveal"
        if (_points.length > 50) { // arbitrary threshold for UX feel
           widget.onScratch(55.0); // Trigger complete
        }
      },
      child: CustomPaint(
        foregroundPainter: _ScratchPainter(points: _points),
        child: widget.cover,
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<Offset> points;
  _ScratchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // We want to "Erase" the cover.
    // Since we are painting ON TOP of the cover (foregroundPainter), we can't easily "erase" pixels of the child widget below.
    // TRICK: We actually should have the CustomPaint be the cover itself, painting the Gold, and then we skip painting where points are.
    
    // Changing approach: Paint Gold layer manually, and clip out the holes.
    var paint = Paint()..color = const Color(0xFFFFD700); // We will use a gradient shader instead
    
    // Create a path for the full rectangle
    Path fullRect = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Create a path for all the "scratches"
    Path scratches = Path();
    for (var p in points) {
      scratches.addOval(Rect.fromCircle(center: p, radius: 25)); // Brush size
    }
    
    // Combine: Result = FullRect - Scratches
    Path result = Path.combine(PathOperation.difference, fullRect, scratches);
    
    // Paint the result
    var gradient = const LinearGradient(
      colors: [AppTheme.goldStart, AppTheme.vividGold, Color(0xFFB8860B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    paint.shader = gradient;
    canvas.drawPath(result, paint);
    
    // Add texture/text on top of the gold (only where gold exists)
    // This is hard with just paths.
    // For simplicity in this constrained no-package env, solid/gradient gold with holes is acceptable.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
