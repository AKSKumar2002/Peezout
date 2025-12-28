import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/referral_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'members_screen.dart';
import 'bank_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final referralProvider = Provider.of<ReferralProvider>(context);
    final user = authProvider.currentUser;

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
              children: [
                // Custom AppBar
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else if (onBackToHome != null) {
                            onBackToHome!();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'MY PROFILE',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance centering
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 32),
                
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.premiumDarkGradient, // Using dark gradient for contrast against outer gradient
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.vividGold, width: 2),
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.surface,
                          backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                          child: user?.profileImage == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white54)
                              : null,
                        ),
                      ).animate().scale(curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      Text(
                        user?.name ?? 'Earner',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 4),

                      Text(
                        user?.email ?? 'email@example.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            context,
                            icon: Icons.people_outline,
                            value: '${referralProvider.totalReferrals}',
                            label: 'Referrals',
                            delay: 400,
                          ),
                          Container(width: 1, height: 40, color: Colors.white12),
                          _buildStatItem(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            value: '₹${walletProvider.wallet.totalEarnings.toStringAsFixed(0)}',
                            label: 'Earned',
                            delay: 500,
                            isGold: true,
                          ),
                          Container(width: 1, height: 40, color: Colors.white12),
                          _buildStatItem(
                            context,
                            icon: Icons.star_outline,
                            value: '${referralProvider.currentLevel + 1}',
                            label: 'Level',
                            delay: 600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Referral Code Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.violetGradient.scale(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.purpleGlow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR REFERRAL CODE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user?.referralCode ?? '------',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: user?.referralCode ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code Copied!'), backgroundColor: AppTheme.successGreen),
                              );
                            },
                            icon: const Icon(Icons.copy, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {
                              final link = referralProvider.getReferralLink(user?.referralCode ?? '');
                              Share.share('Join me! Code: ${user?.referralCode}\n\n$link');
                            },
                            icon: const Icon(Icons.share, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms).slideX(),

                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  delay: 800,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.group_outlined,
                  title: 'My Team',
                  subtitle: '${referralProvider.totalReferrals} members',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MembersScreen()),
                  ),
                  delay: 900,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Details',
                  subtitle: user?.bankName != null && user!.bankName!.isNotEmpty ? user.bankName : 'Add your bank details',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankDetailsScreen())),
                  delay: 1000,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: () => _showAboutDialog(context),
                  delay: 1100,
                ),
                
                const SizedBox(height: 24),
                
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: AppTheme.errorRed,
                  onTap: () async {
                     final confirm = await showDialog<bool>(
                      context: context, 
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surface,
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Logout", style: TextStyle(color: AppTheme.errorRed))),
                        ],
                      )
                    );
                    if (confirm == true && context.mounted) {
                      authProvider.logout();
                       Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                    }
                  },
                  delay: 1200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required int delay,
    bool isGold = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: isGold ? AppTheme.vividGold : Colors.white60, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isGold ? AppTheme.vividGold : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white38,
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).scale();
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.white).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: iconColor ?? Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                         subtitle,
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 14),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white12)),
        title: const Text("About", style: TextStyle(color: Colors.white)),
        content: const Text("Referral Earn App v1.0\n\nA premium experience for earning rewards.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }
}
