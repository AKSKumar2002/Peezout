import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';
import '../models/wallet_model.dart';

class WalletProvider with ChangeNotifier {
  WalletModel _wallet = WalletModel(
    depositBalance: 0,
    earningsBalance: 0,
    totalEarnings: 0,
    transactions: [],
  );

  bool _hasInitialDeposit = false;
  bool _isProcessing = false;

  WalletModel get wallet => _wallet;
  bool get hasInitialDeposit => _hasInitialDeposit;
  bool get isProcessing => _isProcessing;

  // Initialize wallet from storage
  Future<void> initializeWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final walletJson = prefs.getString('wallet');
      final hasDeposit = prefs.getBool('hasInitialDeposit') ?? false;

      if (walletJson != null) {
        _wallet = WalletModel.fromJson(jsonDecode(walletJson));
      }
      _hasInitialDeposit = hasDeposit;
      notifyListeners();
    } catch (e) {
      // If error, keep default values
    }
  }

  // Save wallet to storage
  Future<void> _saveWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet', jsonEncode(_wallet.toJson()));
    await prefs.setBool('hasInitialDeposit', _hasInitialDeposit);
  }

  // Generate virtual account number
  String generateVirtualAccount() {
    final random = Random();
    final accountNumber = List.generate(12, (_) => random.nextInt(10)).join();
    return accountNumber;
  }

  // Make initial deposit
  Future<bool> makeInitialDeposit(double amount) async {
    if (_hasInitialDeposit) return false;

    _isProcessing = true;
    notifyListeners();

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      final transaction = Transaction(
        id: const Uuid().v4(),
        type: TransactionType.deposit,
        amount: amount,
        date: DateTime.now(),
        status: TransactionStatus.completed,
        description: 'Initial deposit',
        referenceId: 'REF${DateTime.now().millisecondsSinceEpoch}',
      );

      _wallet = WalletModel(
        depositBalance: amount,
        earningsBalance: _wallet.earningsBalance,
        totalEarnings: _wallet.totalEarnings,
        transactions: [transaction, ..._wallet.transactions],
      );

      _hasInitialDeposit = true;
      await _saveWallet();

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  // Add referral bonus
  Future<void> addReferralBonus(double amount, String referredUserName) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      type: TransactionType.referralBonus,
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      description: 'Referral bonus from $referredUserName',
      referenceId: 'BONUS${DateTime.now().millisecondsSinceEpoch}',
    );

    _wallet = WalletModel(
      depositBalance: _wallet.depositBalance,
      earningsBalance: _wallet.earningsBalance + amount,
      totalEarnings: _wallet.totalEarnings + amount,
      transactions: [transaction, ..._wallet.transactions],
    );

    await _saveWallet();
    notifyListeners();
  }

  // Add referral earning (alias for addReferralBonus)
  Future<void> addReferralEarning(double amount, String description) async {
    return addReferralBonus(amount, description);
  }


  // Add game reward
  Future<void> addGameReward(double amount, String gameName) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      type: TransactionType.gameReward,
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      description: 'Reward from $gameName',
      referenceId: 'GAME${DateTime.now().millisecondsSinceEpoch}',
    );

    _wallet = WalletModel(
      depositBalance: _wallet.depositBalance,
      earningsBalance: _wallet.earningsBalance + amount,
      totalEarnings: _wallet.totalEarnings + amount,
      transactions: [transaction, ..._wallet.transactions],
    );

    await _saveWallet();
    notifyListeners();
  }

  // Withdraw earnings
  Future<bool> withdrawEarnings(double amount) async {
    if (amount > _wallet.earningsBalance) return false;

    _isProcessing = true;
    notifyListeners();

    try {
      // Simulate withdrawal processing
      await Future.delayed(const Duration(seconds: 3));

      final transaction = Transaction(
        id: const Uuid().v4(),
        type: TransactionType.withdrawal,
        amount: amount,
        date: DateTime.now(),
        status: TransactionStatus.completed,
        description: 'Withdrawal to bank account',
        referenceId: 'WD${DateTime.now().millisecondsSinceEpoch}',
      );

      _wallet = WalletModel(
        depositBalance: _wallet.depositBalance,
        earningsBalance: _wallet.earningsBalance - amount,
        totalEarnings: _wallet.totalEarnings,
        transactions: [transaction, ..._wallet.transactions],
      );

      await _saveWallet();

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _wallet.transactions.where((t) => t.type == type).toList();
  }

  // Get recent transactions
  List<Transaction> getRecentTransactions({int limit = 10}) {
    return _wallet.transactions.take(limit).toList();
  }
}
