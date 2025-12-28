import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/referral_provider.dart';
import '../../utils/app_theme.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Map<String, dynamic>> _sheetReferrals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final referralProvider = Provider.of<ReferralProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      final referrals = await referralProvider.getSheetReferrals(userId);
      setState(() {
        _sheetReferrals = referrals;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final referralProvider = Provider.of<ReferralProvider>(context);
    final localReferrals = referralProvider.referredUsers;

    // Combine local and sheet referrals
    final allReferrals = [...localReferrals];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'MY TEAM',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

              // Statistics Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.violetGradient.scale(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.purpleGlow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Total Members', '${allReferrals.length + _sheetReferrals.length}', Icons.people),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStat(
                        'Total Earnings',
                        '₹${_calculateTotalEarnings()}',
                        Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).scale(),

              const SizedBox(height: 24),

              // Members List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.vividGold))
                    : (allReferrals.isEmpty && _sheetReferrals.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 80, color: Colors.white.withOpacity(0.2)),
                                const SizedBox(height: 16),
                                Text(
                                  'No referrals yet',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start referring to build your team',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: allReferrals.length + _sheetReferrals.length,
                            itemBuilder: (context, index) {
                              if (index < allReferrals.length) {
                                // Local referral
                                final referral = allReferrals[index];
                                return _buildMemberCard(
                                  name: referral.name,
                                  joinDate: referral.joinedDate,
                                  depositAmount: referral.depositAmount,
                                  commission: referral.depositAmount * 0.20,
                                  level: referral.level,
                                  delay: index,
                                );
                              } else {
                                // Sheet referral
                                final sheetIndex = index - allReferrals.length;
                                final referral = _sheetReferrals[sheetIndex];
                                return _buildMemberCard(
                                  name: referral['referredUserName'] ?? 'Unknown',
                                  joinDate: DateTime.tryParse(referral['joinDate'] ?? '') ?? DateTime.now(),
                                  depositAmount: referral['depositAmount'] ?? 0.0,
                                  commission: referral['commissionEarned'] ?? 0.0,
                                  level: referral['level'] ?? 1,
                                  delay: index,
                                  isFromSheet: true,
                                );
                              }
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.vividGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard({
    required String name,
    required DateTime joinDate,
    required double depositAmount,
    required double commission,
    required int level,
    required int delay,
    bool isFromSheet = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isFromSheet)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.vividGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Synced',
                            style: TextStyle(
                              color: AppTheme.vividGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joined: ${DateFormat('dd MMM yyyy').format(joinDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        'Deposit: ₹${depositAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.trending_up, size: 14, color: AppTheme.successGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Earned: ₹${commission.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Level Badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.vividGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 16, color: AppTheme.vividGold),
                  const SizedBox(height: 4),
                  Text(
                    'L$level',
                    style: const TextStyle(
                      color: AppTheme.vividGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (delay * 100).ms).slideX(begin: 0.2, end: 0);
  }

  String _calculateTotalEarnings() {
    double total = 0;
    
    // From local referrals
    final referralProvider = Provider.of<ReferralProvider>(context, listen: false);
    for (var referral in referralProvider.referredUsers) {
      total += referral.depositAmount * 0.20;
    }
    
    // From sheet referrals
    for (var referral in _sheetReferrals) {
      total += referral['commissionEarned'] ?? 0.0;
    }
    
    return total.toStringAsFixed(0);
  }
}
