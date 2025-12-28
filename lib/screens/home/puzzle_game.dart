import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui'; // For image filter

class PuzzleGame extends StatefulWidget {
  final Function(double) onWin;
  
  const PuzzleGame({super.key, required this.onWin});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> with TickerProviderStateMixin {
  // Tile state: index 0 is empty. 
  // We track the *value* at each *position*.
  // But for smooth animation, it is better to track the *position* of each *value*.
  // valuePositions[k] = index where tile with number k is currently located (0..8)
  late List<int> _currentPositions;  
  
  final int _gridSize = 3;
  int _moves = 0;
  bool _isCompleted = false;
  late ConfettiController _confettiController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _initializePuzzle();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  // Calculate solvable permutation
  void _initializePuzzle() {
    // Generate solved state first: positions[val] = correct_index
    // val 1 at index 0, val 2 at index 1... val 8 at index 7, val 0 (empty) at index 8
    
    // We need a list where list[i] is the value at index i
    List<int> gridState = List.generate(_gridSize * _gridSize - 1, (index) => index + 1);
    gridState.add(0); // 0 is empty
    
    do {
      gridState.shuffle();
    } while (!_isSolvable(gridState) || _isSolved(gridState));
    
    // Now convert to our coordinate system if needed, or just keep gridState
    // Let's stick to: _currentPositions[i] = value at index i
    // This maps straightforwardly to a GridView, but for Stack/AnimatedAlign 
    // we want to know: Where is Tile #1? Where is Tile #2?
    
    _currentPositions = List<int>.from(gridState);

    setState(() {
      _moves = 0;
      _isCompleted = false;
    });
  }

  bool _isSolvable(List<int> state) {
    int inversions = 0;
    for (int i = 0; i < state.length - 1; i++) {
      for (int j = i + 1; j < state.length; j++) {
        if (state[i] > 0 && state[j] > 0 && state[i] > state[j]) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0;
  }

  bool _isSolved(List<int> state) {
    for (int i = 0; i < state.length - 1; i++) {
      if (state[i] != i + 1) return false;
    }
    return state.last == 0;
  }

  void _moveTile(int index) {
    if (_isCompleted) return;

    // index is the grid position tapped (0..8)
    // We need to find where the Empty Tile (0) is
    final emptyIndex = _currentPositions.indexOf(0);
    
    final row = index ~/ _gridSize;
    final col = index % _gridSize;
    final emptyRow = emptyIndex ~/ _gridSize;
    final emptyCol = emptyIndex % _gridSize;

    // Check adjacency
    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      
      setState(() {
        // Swap values
        final temp = _currentPositions[index];
        _currentPositions[index] = _currentPositions[emptyIndex];
        _currentPositions[emptyIndex] = temp;
        // _currentPositions now has 0 at 'index' and 'temp' at 'emptyIndex'
        
        _moves++;
      });

      if (_isSolved(_currentPositions)) {
        setState(() {
          _isCompleted = true;
        });
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 600), _showWinDialog);
      }
    }
  }

  void _showWinDialog() {
    final reward = math.max(100 - _moves * 2, 30).toDouble();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: AppTheme.vividGold, width: 2)),
          title: Column(
            children: [
               ShaderMask(
                 shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                 child: const Icon(Icons.stars, size: 80, color: Colors.white),
               ).animate().scale(curve: Curves.elasticOut, duration: 800.ms).rotate(),
               const SizedBox(height: 20),
               Text(
                "MAGNIFICENT!",
                style: GoogleFonts.outfit(
                  color: AppTheme.vividGold, 
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.5, end: 0),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("MOVES", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
                    Text("$_moves", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("REWARD", style: GoogleFonts.outfit(color: AppTheme.neonGreen, fontSize: 14, letterSpacing: 4)),
              const SizedBox(height: 5),
              Text(
                "₹${reward.toStringAsFixed(0)}",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    BoxShadow(color: AppTheme.neonGreen.withOpacity(0.6), blurRadius: 30),
                  ],
                ),
              ).animate().shimmer(duration: 2.seconds),
            ],
          ),
          actions: [
            Center(
               child: Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(30),
                   gradient: AppTheme.goldGradient,
                   boxShadow: const [BoxShadow(color: AppTheme.goldStart, blurRadius: 15, spreadRadius: -5)],
                 ),
                 child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onWin(reward);
                    Navigator.pop(context); // Pop game screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    "CLAIM REWARD", 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)
                  ),
                ),
               ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with premium gradient
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text("MYSTIC PUZZLE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 20, color: AppTheme.vividGold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                onPressed: () {
                   setState(() {
                     _moves = 0;
                     _isCompleted = false;
                   });
                   _initializePuzzle();
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF2A2A2A),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphic Moves Counter
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "MOVES",
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 14,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 1, height: 20, color: Colors.white24),
                            const SizedBox(width: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, anim) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(anim), child: FadeTransition(opacity: anim, child: child)),
                              child: Text(
                                "$_moves",
                                key: ValueKey(_moves),
                                style: GoogleFonts.outfit(
                                  color: AppTheme.vividGold,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // The Game Board
                  Center(
                    child: Container(
                      width: 320,
                      height: 320,
                      padding: const EdgeInsets.all(10), // Padding inside the frame
                      decoration: BoxDecoration(
                        color: const Color(0xFF050505),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: AppTheme.goldStart.withOpacity(0.1), blurRadius: 40, spreadRadius: -5),
                          // Inner shadow for sinking effect
                          const BoxShadow(color: Colors.black, blurRadius: 15, offset: Offset(5, 5), spreadRadius: 5),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Stack(
                        children: [
                          // CORRECT ANIMATION LOGIC:
                          // We render a generic set of tiles for numbers 1..8.
                          // For each number, we find its current index in the _currentPositions list.
                          // That index determines its Top/Left.
                          // This ensures the Widget Key ("Tile-1", "Tile-2") stays constant,
                          // allowing AnimatedPositioned to actually animate the move.
                          
                          for (int number = 1; number < (_gridSize * _gridSize); number++)
                            Builder(
                              builder: (context) {
                                // Find where this number currently lives in the grid
                                final currentGridIndex = _currentPositions.indexOf(number);
                                if (currentGridIndex == -1) return const SizedBox(); // Should not happen
                                
                                return _buildAnimatedTile(positionIndex: currentGridIndex, value: number);
                              },
                            ),
                          
                          // Invisible touch targets grid
                          // These stay static at grid positions to catch taps
                          for (int i = 0; i < _gridSize * _gridSize; i++)
                            _buildTouchTarget(i),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  
                  Text(
                    "Tap tiles to slide them into place",
                    style: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: math.pi / 2,
            maxBlastForce: 10, 
            minBlastForce: 5,
            emissionFrequency: 0.05,
            numberOfParticles: 20, 
            gravity: 0.2,
            colors: const [AppTheme.vividGold, AppTheme.goldStart, Colors.white, AppTheme.neonGreen], 
          ),
        ),
      ],
    );
  }

  // Positioning Logic
  // Grid is 3x3. Container is 320x320. Padding 10. Inner size 300x300.
  // Tile size ~ 92x92 with 4px gap.
  // We need precise positioning.
  
  double _getTileSize() => 92.0;
  double _getGap() => 8.0;

  Widget _buildAnimatedTile({required int positionIndex, required int value}) {
    final row = positionIndex ~/ _gridSize;
    final col = positionIndex % _gridSize;
    
    final top = row * (_getTileSize() + _getGap());
    final left = col * (_getTileSize() + _getGap());

    // We use AnimatedAlign or AnimatedPositioned. AnimatedPositioned is absolute inside Stack.
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      top: top,
      left: left,
      width: _getTileSize(),
      height: _getTileSize(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Base Gold Material
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              
              // Glossy Overlay (Glassmorphism)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Inner Border
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),

              // Number
              Center(
                child: Text(
                  "$value",
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3E2723), // Dark wood/gold tint
                    shadows: [
                      const Shadow(color: Colors.white30, offset: Offset(1, 1), blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Touchable grid to handle taps correctly even while animations are playing
  Widget _buildTouchTarget(int index) {
    final row = index ~/ _gridSize;
    final col = index % _gridSize;
    
    final top = row * (_getTileSize() + _getGap());
    final left = col * (_getTileSize() + _getGap());

    return Positioned(
      top: top,
      left: left,
      width: _getTileSize(),
      height: _getTileSize(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _moveTile(index),
        child: Container(color: Colors.transparent), // invisible hit box
      ),
    );
  }
}
