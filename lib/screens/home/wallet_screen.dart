import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/wallet_model.dart';

class WalletScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  final bool isDepositMode;
  
  const WalletScreen({
    super.key, 
    this.onBackToHome, 
    this.isDepositMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallet = walletProvider.wallet;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          isDepositMode ? "ADD FUNDS" : "MY WALLET",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: (Navigator.canPop(context) || onBackToHome != null)
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (onBackToHome != null) {
                    onBackToHome!();
                  }
                },
              ),
            )
          : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppTheme.violetGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppTheme.purpleGlow,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Earnings",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "₹${wallet.totalEarnings.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 48, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(height: 1, color: Colors.white24),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Deposit Funds", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                              const SizedBox(height: 4),
                              Text(
                                "₹${wallet.depositBalance.toStringAsFixed(0)}", 
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Withdrawable", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.vividGold)),
                              const SizedBox(height: 4),
                              Text(
                                "₹${wallet.earningsBalance.toStringAsFixed(0)}", 
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.vividGold, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 32),

                // Actions
                if (isDepositMode)
                  ElevatedButton(
                    onPressed: () => _showDepositDialog(context, walletProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.vividGold),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text("DEPOSIT FUNDS"),
                  ).animate().fadeIn(delay: 400.ms)
                else
                  ElevatedButton(
                    onPressed: () => _showWithdrawDialog(context, walletProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.vividGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text("WITHDRAW NOW"),
                  ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 48),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 4, height: 20, color: AppTheme.vividGold, margin: const EdgeInsets.only(right: 12)),
                    Text("History", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wallet.transactions.length,
                  itemBuilder: (context, index) {
                    final t = wallet.transactions[index];
                    final isPositive = t.type == TransactionType.deposit || t.type == TransactionType.referralBonus || t.type == TransactionType.gameReward;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPositive ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          t.description ?? "Transaction", 
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)
                        ),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(t.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
                        ),
                        trailing: Text(
                          "${isPositive ? '+' : '-'} ₹${t.amount.toStringAsFixed(0)}",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isPositive ? AppTheme.successGreen : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().slideX(delay: (400 + (index * 100)).ms, begin: 0.1, end: 0);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, WalletProvider provider) {
    final virtualAccount = "VPA${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Center(child: Text("Deposit Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Transfer funds to this Virtual ID:", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black45, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.vividGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(virtualAccount, style: const TextStyle(color: AppTheme.vividGold, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                  const SizedBox(width: 12),
                  Icon(Icons.copy, color: AppTheme.vividGold.withOpacity(0.5), size: 18),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Minimum Deposit: ₹100", style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context), 
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.2))),
                  child: const Text("CLOSE", style: TextStyle(color: Colors.white70))
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.makeInitialDeposit(500); 
                    authProvider.activateDepositStatus();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deposit Completed Successfully!"), backgroundColor: AppTheme.successGreen));
                  },
                  child: const Text("I'VE PAID"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WalletProvider provider) {
    if (provider.wallet.earningsBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No earnings to withdraw!"), backgroundColor: AppTheme.errorRed));
      return;
    }

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Center(child: Text("Withdraw Earnings", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Available Balance", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60)),
            const SizedBox(height: 8),
            Text("₹${provider.wallet.earningsBalance}", style: const TextStyle(color: AppTheme.successGreen, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Enter Amount",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixText: "₹ ",
                prefixStyle: const TextStyle(color: Colors.white, fontSize: 18),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text("Funds will be transferred to your registered bank account.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context), 
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.2))),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white70))
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0 && amount <= provider.wallet.earningsBalance) {
                       Navigator.pop(context);
                       await provider.withdrawEarnings(amount);
                       if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Withdrawal Request Processed!"), backgroundColor: AppTheme.successGreen));
                       }
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Amount"), backgroundColor: AppTheme.errorRed));
                    }
                  },
                  child: const Text("WITHDRAW"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
