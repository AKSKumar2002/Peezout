import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/referral_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import 'wallet_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ReferralProvider>(
      builder: (context, authProvider, referralProvider, child) {
        final user = authProvider.currentUser;
        final currentLevelIndex = referralProvider.currentLevel;
        final currentUILevel = currentLevelIndex + 1;
        final totalReferrals = referralProvider.totalReferrals;
        
        // Helper to check task status
        final currentTask = referralProvider.currentTask;
        final bool isReferralTaskComplete = currentTask != null && 
                                            currentTask.requiredReferrals != -1 && 
                                            currentTask.currentReferrals >= currentTask.requiredReferrals;
        final bool canPlayGamesUI = currentTask != null && currentTask.canPlayGames;
        
        final levelRequirements = [1, 6, 12, 18, 50, 999];
        final safeLevelIndex = (currentUILevel - 1).clamp(0, levelRequirements.length - 1);
        final currentReq = levelRequirements[safeLevelIndex];
        
        final isDepositActive = user?.isDepositActive ?? false;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppTheme.background,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.premiumDarkGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back,",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white60,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? "Earner",
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: IconButton(
                            onPressed: () {}, 
                            icon: const Icon(Icons.notifications_outlined, color: AppTheme.champagneGold),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Current Status Card - Glassmorphism Premium
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.glassGradient,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: AppTheme.vividGold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "ACTIVE TASK",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.vividGold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.glowShadow,
                                ),
                                child: SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: CircularProgressIndicator(
                                    value: currentReq > 0 && currentReq != 999 
                                        ? ((totalReferrals % currentReq) / currentReq).clamp(0.0, 1.0) 
                                        : (currentReq == 999 ? 1.0 : 0),
                                    backgroundColor: Colors.white10,
                                    color: AppTheme.vividGold,
                                    strokeWidth: 8,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentReq == 999 
                                        ? "∞" 
                                        : "${(currentTask?.currentReferrals ?? 0)}/$currentReq",
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Referrals",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),
                    
                    // Action Button with Shine
                    Container(
                      width: double.infinity,
                      decoration: isDepositActive ? BoxDecoration(
                        boxShadow: AppTheme.glowShadow,
                        borderRadius: BorderRadius.circular(20),
                      ) : null,
                      child: ElevatedButton(
                        onPressed: isDepositActive 
                          ? () {
                              Clipboard.setData(ClipboardData(text: user?.referralCode ?? ""));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Link Copied!"), backgroundColor: AppTheme.successGreen),
                              );
                            }
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDepositActive ? AppTheme.vividGold : Colors.white10,
                          foregroundColor: isDepositActive ? Colors.black : Colors.white24,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy, size: 20, color: isDepositActive ? Colors.black : Colors.white24),
                            const SizedBox(width: 12),
                            const Text("COPY REFERRAL LINK"),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Roadmap Header
                    Row(
                      children: [
                        Container(
                          width: 4, 
                          height: 24, 
                          decoration: BoxDecoration(
                            color: AppTheme.luxuryPurple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Your Journey", 
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Steps
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        _buildRoadmapItem(
                          context, 
                          1, 
                          "Add Cash to Wallet", 
                          isDepositActive, 
                          !isDepositActive, 
                          isDeposit: true,
                          delay: 300,
                          onTap: !isDepositActive ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WalletScreen(isDepositMode: true)),
                            );
                          } : null,
                        ),
                        
                        _buildRoadmapItem(
                          context, 
                          2, 
                          "Refer 1 Person", 
                          isDepositActive && (currentLevelIndex > 0 || isReferralTaskComplete), 
                          isDepositActive && currentLevelIndex == 0 && !isReferralTaskComplete,
                          delay: 400,
                          onTap: (isDepositActive && currentLevelIndex == 0 && !isReferralTaskComplete) ? () {
                            // Demo Referral Action
                            final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                            referralProvider.addDemoReferrals(1, walletProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("New Referral Added! (Demo)"), backgroundColor: AppTheme.successGreen),
                            );
                          } : null,
                        ),

                        _buildRoadmapItem(
                          context, 
                          3, 
                          "Play 3 Games", 
                          isDepositActive && (currentLevelIndex > 0), 
                          isDepositActive && currentLevelIndex == 0 && canPlayGamesUI, 
                          isGame: true,
                          delay: 500,
                          onTap: (isDepositActive && currentLevelIndex == 0 && canPlayGamesUI) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TasksScreen()),
                            );
                          } : null,
                        ),

                        _buildRoadmapItem(
                          context, 
                          4, 
                          "Refer 6 People", 
                          isDepositActive && (currentLevelIndex > 1 || (currentLevelIndex == 1 && referralProvider.isReferralCompleteForLevel(1))), 
                          isDepositActive && currentLevelIndex == 1 && !referralProvider.isReferralCompleteForLevel(1),
                          delay: 600,
                          onTap: (isDepositActive && currentLevelIndex == 1 && !referralProvider.isReferralCompleteForLevel(1)) ? () {
                            final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                            final task = referralProvider.currentTask;
                            if (task != null) {
                              int needed = task.requiredReferrals - task.currentReferrals;
                              if (needed > 0) {
                                referralProvider.addDemoReferrals(needed, walletProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Added $needed Referrals! (Demo)"), backgroundColor: AppTheme.successGreen),
                                );
                              }
                            }
                          } : null,
                        ),
                        
                        _buildRoadmapItem(
                          context, 
                          5, 
                          "Play 3 Games", 
                          isDepositActive && (currentLevelIndex > 1 || (currentLevelIndex == 1 && referralProvider.isGamesCompleteForLevel(1))),
                          isDepositActive && currentLevelIndex == 1 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(1), 
                          isGame: true,
                          delay: 700,
                          onTap: (isDepositActive && currentLevelIndex == 1 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(1)) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TasksScreen()),
                            );
                          } : null,
                        ),
                        
                        _buildRoadmapItem(
                          context, 
                          6, 
                          "Refer 12 People", 
                          isDepositActive && (currentLevelIndex > 2 || (currentLevelIndex == 2 && referralProvider.isReferralCompleteForLevel(2))),
                          isDepositActive && currentLevelIndex == 2 && !referralProvider.isReferralCompleteForLevel(2),
                          delay: 800,
                          onTap: (isDepositActive && currentLevelIndex == 2 && !referralProvider.isReferralCompleteForLevel(2)) ? () {
                             final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                            final task = referralProvider.currentTask;
                            if (task != null) {
                              int needed = task.requiredReferrals - task.currentReferrals;
                              if (needed > 0) {
                                referralProvider.addDemoReferrals(needed, walletProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Added $needed Referrals! (Demo)"), backgroundColor: AppTheme.successGreen),
                                );
                              }
                            }
                          } : null,
                        ),
                        
                        _buildRoadmapItem(
                          context, 
                          7, 
                          "Play 3 Games", 
                          isDepositActive && (currentLevelIndex > 2 || (currentLevelIndex == 2 && referralProvider.isGamesCompleteForLevel(2))),
                          isDepositActive && currentLevelIndex == 2 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(2), 
                          isGame: true,
                          delay: 900,
                          onTap: (isDepositActive && currentLevelIndex == 2 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(2)) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TasksScreen()),
                            );
                          } : null,
                        ),
                        
                         _buildRoadmapItem(
                          context, 
                          8, 
                          "Refer 18 People", 
                          isDepositActive && (currentLevelIndex > 3 || (currentLevelIndex == 3 && referralProvider.isReferralCompleteForLevel(3))),
                          isDepositActive && currentLevelIndex == 3 && !referralProvider.isReferralCompleteForLevel(3),
                          delay: 1000,
                          onTap: (isDepositActive && currentLevelIndex == 3 && !referralProvider.isReferralCompleteForLevel(3)) ? () {
                             final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                            final task = referralProvider.currentTask;
                            if (task != null) {
                              int needed = task.requiredReferrals - task.currentReferrals;
                              if (needed > 0) {
                                referralProvider.addDemoReferrals(needed, walletProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Added $needed Referrals! (Demo)"), backgroundColor: AppTheme.successGreen),
                                );
                              }
                            }
                          } : null,
                        ),
                        
                        _buildRoadmapItem(
                          context, 
                          9, 
                          "Play 3 Games", 
                          isDepositActive && (currentLevelIndex > 3 || (currentLevelIndex == 3 && referralProvider.isGamesCompleteForLevel(3))),
                          isDepositActive && currentLevelIndex == 3 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(3), 
                          isGame: true,
                          delay: 1100,
                          onTap: (isDepositActive && currentLevelIndex == 3 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(3)) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TasksScreen()),
                            );
                          } : null,
                        ),

                        _buildRoadmapItem(
                          context, 
                          10, 
                          "Refer 50 People", 
                          isDepositActive && (currentLevelIndex > 4 || (currentLevelIndex == 4 && referralProvider.isReferralCompleteForLevel(4))),
                          isDepositActive && currentLevelIndex == 4 && !referralProvider.isReferralCompleteForLevel(4),
                          delay: 1200,
                          onTap: (isDepositActive && currentLevelIndex == 4 && !referralProvider.isReferralCompleteForLevel(4)) ? () {
                             final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                            final task = referralProvider.currentTask;
                            if (task != null) {
                              int needed = task.requiredReferrals - task.currentReferrals;
                              if (needed > 0) {
                                referralProvider.addDemoReferrals(needed, walletProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Added $needed Referrals! (Demo)"), backgroundColor: AppTheme.successGreen),
                                );
                              }
                            }
                          } : null,
                        ),
                        
                        _buildRoadmapItem(
                          context, 
                          11, 
                          "Play 3 Games", 
                          isDepositActive && (currentLevelIndex > 4 || (currentLevelIndex == 4 && referralProvider.isGamesCompleteForLevel(4))),
                          isDepositActive && currentLevelIndex == 4 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(4), 
                          isGame: true,
                          delay: 1300,
                          onTap: (isDepositActive && currentLevelIndex == 4 && canPlayGamesUI && !referralProvider.isGamesCompleteForLevel(4)) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TasksScreen()),
                            );
                          } : null,
                        ),

                        _buildRoadmapItem(
                          context, 
                          12, 
                          "Unlimited Referrals", 
                          isDepositActive && currentLevelIndex >= 5, 
                          isDepositActive && currentLevelIndex == 5,
                          delay: 1400,
                          onTap: (isDepositActive && currentLevelIndex == 5) ? () {
                            final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                            // For unlimited, just add small batch at a time
                            referralProvider.addDemoReferrals(5, walletProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Added 5 More Referrals! (Demo)"), backgroundColor: AppTheme.successGreen),
                            );
                          } : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRoadmapItem(
    BuildContext context, 
    int level, 
    String title, 
    bool unlocked, 
    bool active, 
    {bool isGame = false, bool isDeposit = false, VoidCallback? onTap, int delay = 0}
  ) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              // Line Top
              Container(
                width: 2,
                height: 24,
                color: unlocked ? AppTheme.vividGold : Colors.white12,
              ),
              // Indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppTheme.vividGold : (unlocked ? AppTheme.antiqueGold : AppTheme.deepCharcoal),
                  border: Border.all(
                    color: active ? AppTheme.vividGold : (unlocked ? AppTheme.antiqueGold : Colors.white12),
                    width: 2,
                  ),
                  boxShadow: active ? AppTheme.glowShadow : [],
                ),
                child: Center(
                  child: unlocked 
                    ? const Icon(Icons.check, size: 20, color: Colors.black)
                    : Text("$level", style: TextStyle(color: active ? Colors.black : Colors.white54, fontWeight: FontWeight.bold)),
                ),
              ),
              // Line Bottom
              Expanded(
                child: Container(
                  width: 2,
                  color: unlocked ? AppTheme.vividGold : Colors.white12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: active ? AppTheme.surface : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: active 
                    ? Border.all(color: AppTheme.vividGold.withOpacity(0.5)) 
                    : Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: active ? [
                    BoxShadow(color: AppTheme.vividGold.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.vividGold.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDeposit ? Icons.account_balance_wallet_outlined : (isGame ? Icons.games_outlined : Icons.person_add_outlined),
                        color: active ? AppTheme.vividGold : Colors.white54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: active ? Colors.white : Colors.white38,
                          fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!unlocked && !active) const Icon(Icons.lock_outline, size: 18, color: Colors.white24),
                    if (onTap != null && active) const Icon(Icons.arrow_forward, size: 18, color: AppTheme.vividGold),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}
