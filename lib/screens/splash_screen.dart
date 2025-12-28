import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/referral_provider.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final referralProvider = Provider.of<ReferralProvider>(context, listen: false);

    // Initialize providers
    await authProvider.checkAuthStatus();
    await walletProvider.initializeWallet();
    await referralProvider.initializeTasks();

    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Navigate based on authentication status
    // Note: Previous flow used MainScreen or HomeScreen. 
    // Assuming HomeScreen is sufficient given previous context of "Removal of bottom nav".
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => authProvider.isAuthenticated
            ? const MainScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowShadow,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  size: 70,
                  color: Colors.black, // Dark icon on Gold background
                ),
              )
              .animate()
              .scale(duration: 800.ms, curve: Curves.elasticOut)
              .shimmer(duration: 2000.ms, delay: 500.ms, color: Colors.white54),
              
              const SizedBox(height: 48),
              
              // App Name
              Text(
                'REFERRAL EARN',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: AppTheme.vividGold.withOpacity(0.5),
                      offset: const Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Tagline
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTag("REFER"),
                  _buildDot(),
                  _buildTag("EARN"),
                  _buildDot(),
                  _buildTag("GROW"),
                ],
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms),
              
              const SizedBox(height: 80),
              
              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.vividGold,
                  ),
                  strokeWidth: 3,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.vividGold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white38,
        shape: BoxShape.circle,
      ),
    );
  }
}
