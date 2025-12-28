import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/referral_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import 'spin_wheel_game.dart';
import 'puzzle_game.dart';
import 'scratch_card_game.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Local state to track played games
  final Map<String, bool> _gamesPlayed = {
    'Spin': false,
    'Puzzle': false,
    'Scratch': false,
  };

  @override
  void initState() {
    super.initState();
    _loadGameProgress();
  }

  Future<void> _loadGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gamesPlayed['Spin'] = prefs.getBool('game_completed_Spin') ?? false;
      _gamesPlayed['Puzzle'] = prefs.getBool('game_completed_Puzzle') ?? false;
      _gamesPlayed['Scratch'] = prefs.getBool('game_completed_Scratch') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final referralProvider = Provider.of<ReferralProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    final areGamesUnlocked = referralProvider.canPlayGames;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "GAME CENTER",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.violetGradient.scale(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.purpleGlow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        areGamesUnlocked 
                          ? "Unlock the next level by playing all 3 games!" 
                          : "Refer more people to unlock the Gaming Arena.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().slideY(begin: -0.2, end: 0).fadeIn(),
                
                const SizedBox(height: 32),

                // Game 1: Spin
                _buildGameCard(
                  context,
                  title: "Spin & Win",
                  subtitle: "Try your luck on the wheel",
                  icon: Icons.pie_chart_outline,
                  color: AppTheme.luxuryPurple,
                  isLocked: !areGamesUnlocked,
                  isPlayed: _gamesPlayed['Spin']!,
                  onPlay: () => _playGame('Spin', walletProvider),
                  delay: 200,
                ),
                const SizedBox(height: 20),
                
                // Game 2: Puzzle
                _buildGameCard(
                  context,
                  title: "Puzzle Challenge",
                  subtitle: "Solve to earn rewards",
                  icon: Icons.extension_outlined,
                  color: AppTheme.vividGold, // Gold
                  isLocked: !areGamesUnlocked || !_gamesPlayed['Spin']!,
                  isPlayed: _gamesPlayed['Puzzle']!,
                  onPlay: () => _playGame('Puzzle', walletProvider),
                  delay: 300,
                ),
                const SizedBox(height: 20),
                
                // Game 3: Scratch
                _buildGameCard(
                  context,
                  title: "Scratch & Reveal",
                  subtitle: "Instant win scratch cards", 
                  icon: Icons.style_outlined,
                  color: AppTheme.neonCyan, // Cyan
                  isLocked: !areGamesUnlocked || !_gamesPlayed['Puzzle']!,
                  isPlayed: _gamesPlayed['Scratch']!,
                  onPlay: () => _playGame('Scratch', walletProvider),
                  delay: 400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playGame(String game, WalletProvider walletProvider) async {
    if (game == 'Spin') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpinWheelGame(
            onWin: (amount) => _handleWin(game, amount, walletProvider),
          ),
        ),
      );
      return;
    } else if (game == 'Puzzle') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleGame(
            onWin: (amount) => _handleWin(game, amount, walletProvider),
          ),
        ),
      );
      return;
    } else if (game == 'Scratch') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScratchCardGame(
            onWin: (amount) => _handleWin(game, amount, walletProvider),
          ),
        ),
      );
      return;
    }
  }

  void _handleWin(String game, double amount, WalletProvider walletProvider) async {
    await walletProvider.addGameReward(amount, "Won $game");
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('game_completed_$game', true);

    if (mounted) {
      setState(() {
        _gamesPlayed[game] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You earned ₹${amount.toStringAsFixed(0)}!"), backgroundColor: AppTheme.successGreen),
      );
      
      // Check if all games played
      if (_gamesPlayed.values.every((played) => played)) {
        final refProvider = Provider.of<ReferralProvider>(context, listen: false);
        await refProvider.completeGames();
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Level Complete! Next Referral Link Unlocked."), backgroundColor: AppTheme.vividGold),
        );
      }
    }
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLocked,
    required bool isPlayed,
    required VoidCallback onPlay,
    int delay = 0,
  }) {
    final glow = !isLocked && !isPlayed;
    
    return GestureDetector(
      onTap: isLocked || isPlayed ? null : onPlay,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: glow ? color.withOpacity(0.5) : Colors.white10,
            width: 1,
          ),
          boxShadow: glow 
            ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 24, spreadRadius: 0)] 
            : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLocked ? Colors.white.withOpacity(0.05) : color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: isLocked ? Colors.transparent : color.withOpacity(0.5)),
              ),
              child: Icon(
                icon, 
                color: isLocked ? Colors.white24 : color, 
                size: 28
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isLocked ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPlayed ? "Completed" : (isLocked ? "Locked" : subtitle),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isPlayed ? AppTheme.successGreen : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_outline, color: Colors.white24)
            else if (isPlayed)
              const Icon(Icons.check_circle, color: AppTheme.successGreen)
            else
               Icon(Icons.play_circle_fill, color: color, size: 32),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
