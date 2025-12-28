import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/referral_provider.dart';
import '../../services/google_sheets_service.dart';
import 'main_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int? _selectedAmount;
  bool _isLoading = false;

  final List<int> _amounts = [100, 500, 1000];

  void _handleDeposit() async {
    if (_selectedAmount == null) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final referralProvider = Provider.of<ReferralProvider>(context, listen: false);
      final sheetsService = GoogleSheetsService();
      final currentUser = authProvider.currentUser;
      
      // Update wallet balance
      await walletProvider.makeInitialDeposit(_selectedAmount!.toDouble());

      // Update user state to active deposit
      await authProvider.activateDepositStatus();
      
      // Save deposit to Google Sheets
      if (currentUser != null) {
        String? referrerUserId;
        double? commission;
        
        // If user was referred, calculate and distribute commission
        if (currentUser.referredBy != null && currentUser.referredBy!.isNotEmpty) {
          // Get referrer info from Google Sheets
          final referrerInfo = await sheetsService.getUserByReferralCode(currentUser.referredBy!);
          if (referrerInfo != null) {
            final referrerId = referrerInfo['userId'] as String?;
            if (referrerId != null) {
              referrerUserId = referrerId;
              commission = _selectedAmount!.toDouble() * 0.20;
              
              // Track referral with commission in Google Sheets
              await referralProvider.addReferralWithTracking(
                referrerUserId: referrerId,
                referrerName: referrerInfo['name'] as String,
                referredUserId: currentUser.id,
                referredUserName: currentUser.name,
                referredUserEmail: currentUser.email,
                referredUserPhone: currentUser.phone,
                depositAmount: _selectedAmount!.toDouble(),
                walletProvider: walletProvider,
              );
            }
          }
        }
        
        // Save deposit transaction
        await sheetsService.saveDeposit(
          userId: currentUser.id,
          userName: currentUser.name,
          amount: _selectedAmount!.toDouble(),
          timestamp: DateTime.now(),
          referrerUserId: referrerUserId,
          commissionPaid: commission,
        );
      }
      
      // Navigate to Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Activate Your\nEarning Potential",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Select an amount to start referring",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.separated(
                    itemCount: _amounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final amount = _amounts[index];
                      final isSelected = _selectedAmount == amount;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAmount = amount),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.goldStart.withOpacity(0.1) 
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.goldStart : Colors.white.withOpacity(0.1),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.goldStart : Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "₹",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "₹$amount",
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.goldStart,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: Text(
                    "Secure Payment Gateway via Virtual Account",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAmount != null && !_isLoading ? _handleDeposit : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppTheme.goldStart,
                      disabledBackgroundColor: Colors.white10,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Text(
                            "Proceed to Pay ₹${_selectedAmount ?? ''}",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
