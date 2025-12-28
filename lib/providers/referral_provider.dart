import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';
import '../models/referral_model.dart';
import '../services/google_sheets_service.dart';

class ReferralProvider with ChangeNotifier {
  List<ReferralTask> _tasks = [];
  List<ReferredUser> _referredUsers = [];
  int _currentLevel = 0;
  final _sheetsService = GoogleSheetsService();

  List<ReferralTask> get tasks => _tasks;
  List<ReferredUser> get referredUsers => _referredUsers;
  int get currentLevel => _currentLevel;
  ReferralTask? get currentTask => _currentLevel < _tasks.length ? _tasks[_currentLevel] : null;

  // Check if referral requirement is met for a specific level
  bool isReferralCompleteForLevel(int levelIndex) {
    if (levelIndex >= _tasks.length) return false;
    final task = _tasks[levelIndex];
    if (task.requiredReferrals == -1) return false; // Unlimited never "complete"
    return task.currentReferrals >= task.requiredReferrals;
  }

  // Check if games are complete for a specific level
  bool isGamesCompleteForLevel(int levelIndex) {
    if (levelIndex >= _tasks.length) return false;
    return _tasks[levelIndex].gamesCompleted;
  }

  // Initialize referral tasks
  Future<void> initializeTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('referralTasks');
      final usersJson = prefs.getString('referredUsers');
      final level = prefs.getInt('currentLevel') ?? 0;

      if (tasksJson != null) {
        final List<dynamic> tasksList = jsonDecode(tasksJson);
        _tasks = tasksList.map((t) => ReferralTask.fromJson(t)).toList();
      } else {
        _initializeDefaultTasks();
      }

      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _referredUsers = usersList.map((u) => ReferredUser.fromJson(u)).toList();
      }

      _currentLevel = level;
      notifyListeners();
    } catch (e) {
      _initializeDefaultTasks();
    }
  }

  // Initialize default tasks based on requirements
  void _initializeDefaultTasks() {
    _tasks = [
      ReferralTask(
        level: 1,
        requiredReferrals: 1,
        isUnlocked: true,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 0, // Bonus is now per-referral (20% of deposit)
      ),
      ReferralTask(
        level: 2,
        requiredReferrals: 6,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 0,
      ),
      ReferralTask(
        level: 3,
        requiredReferrals: 12,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 0,
      ),
      ReferralTask(
        level: 4,
        requiredReferrals: 18,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 0,
      ),
      ReferralTask(
        level: 5,
        requiredReferrals: 50,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 0,
      ),
      ReferralTask(
        level: 6,
        requiredReferrals: -1, // Unlimited
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 0,
      ),
    ];
    _saveTasks();
  }

  // Save tasks to storage
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    final usersJson = jsonEncode(_referredUsers.map((u) => u.toJson()).toList());
    await prefs.setString('referralTasks', tasksJson);
    await prefs.setString('referredUsers', usersJson);
    await prefs.setInt('currentLevel', _currentLevel);
  }

  // Add a referred user
  Future<void> addReferredUser(String name, double depositAmount) async {
    final user = ReferredUser(
      id: const Uuid().v4(),
      name: name,
      joinedDate: DateTime.now(),
      hasDeposited: true,
      depositAmount: depositAmount,
      level: _currentLevel + 1,
    );

    _referredUsers.add(user);

    // Update current task
    if (_currentLevel < _tasks.length) {
      final currentTask = _tasks[_currentLevel];
      
      // For unlimited level (-1), we don't cap/complete based on referral count alone
      // But for normal levels, we track progress
      
      _tasks[_currentLevel] = currentTask.copyWith(
        currentReferrals: currentTask.currentReferrals + 1,
      );
    }

    await _saveTasks();
    notifyListeners();
  }

  // Mark games as completed for current level
  Future<void> completeGames() async {
    if (_currentLevel < _tasks.length) {
      final currentTask = _tasks[_currentLevel];
      _tasks[_currentLevel] = currentTask.copyWith(
        gamesCompleted: true,
        isCompleted: true,
      );

      // Unlock next level
      if (_currentLevel + 1 < _tasks.length) {
        final nextTask = _tasks[_currentLevel + 1];
        _tasks[_currentLevel + 1] = ReferralTask(
          level: nextTask.level,
          requiredReferrals: nextTask.requiredReferrals,
          isUnlocked: true,
          isCompleted: nextTask.isCompleted,
          currentReferrals: nextTask.currentReferrals,
          gamesCompleted: nextTask.gamesCompleted,
          bonusAmount: nextTask.bonusAmount,
        );
        _currentLevel++;
      }

      await _saveTasks();
      notifyListeners();
    }
  }

  // Get referred users by level
  List<ReferredUser> getReferredUsersByLevel(int level) {
    return _referredUsers.where((u) => u.level == level).toList();
  }

  // Get total referrals count
  int get totalReferrals => _referredUsers.length;

  // Get total earnings from referrals
  // Note: We are now calculating earnings dynamically in the wallet, 
  // but if we want to track it here we can summing up from wallet tx or referred users
  // double get totalReferralEarnings { ... } 

  // Check if can play games
  bool get canPlayGames {
    if (_currentLevel >= _tasks.length) return false;
    final task = _tasks[_currentLevel];
    if (task.requiredReferrals == -1) {
        // Unlimited level logic: maybe play games periodically? 
        // For now, let's say after every 3 referrals? Or just always allowed?
        // User requirement: "play 3 games after that the user can refer unlimited person"
        // This implies the unlimited phase is AFTER the last Play 3 Games. 
        // So effectively, once in unlimited level, maybe no more mandatory games?
        return false; 
    }
    return task.currentReferrals >= task.requiredReferrals && !task.gamesCompleted;
  }

  // Get referral link
  String getReferralLink(String referralCode) {
    return 'https://referral-app.com/join?ref=$referralCode';
  }

  // Simulate adding random referred users (for demo)
  // Now accepts WalletProvider to add commission
  Future<void> addDemoReferrals(int count, dynamic walletProvider) async {
    final random = Random();
    final names = ['John', 'Emma', 'Michael', 'Sophia', 'William', 'Olivia', 'James', 'Ava'];
    
    for (int i = 0; i < count; i++) {
      final name = names[random.nextInt(names.length)];
      final depositAmount = [100.0, 500.0, 1000.0][random.nextInt(3)];
      
      // Calculate 20% commission
      final commission = depositAmount * 0.20;
      
      // Add to referral list
      await addReferredUser(
        '$name ${random.nextInt(100)}',
        depositAmount,
      );
      
      // Add commission to wallet
      if (walletProvider != null) {
        await walletProvider.addReferralEarning(
          commission, 
          "Ref Bonus: 20% of ${depositAmount.toStringAsFixed(0)} ($name)",
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }


  // Add referral with Google Sheets tracking
  Future<void> addReferralWithTracking({
    required String referrerUserId,
    required String referrerName,
    required String referredUserId,
    required String referredUserName,
    required String referredUserEmail,
    required String referredUserPhone,
    required double depositAmount,
    dynamic walletProvider,
  }) async {
    // Calculate 20% commission
    final commission = depositAmount * 0.20;
    
    // Add to local referral list
    await addReferredUser(referredUserName, depositAmount);
    
    // Save to Google Sheets
    await _sheetsService.saveReferral(
      referrerUserId: referrerUserId,
      referrerName: referrerName,
      referredUserId: referredUserId,
      referredUserName: referredUserName,
      referredUserEmail: referredUserEmail,
      referredUserPhone: referredUserPhone,
      joinDate: DateTime.now(),
      depositAmount: depositAmount,
      commissionEarned: commission,
      level: _currentLevel + 1,
    );
    
    // Add commission to wallet
    if (walletProvider != null) {
      await walletProvider.addReferralEarning(
        commission,
        "Ref Bonus: 20% of ${depositAmount.toStringAsFixed(0)} ($referredUserName)",
      );
    }
  }

  // Get referred users from Google Sheets
  Future<List<Map<String, dynamic>>> getSheetReferrals(String userId) async {
    return await _sheetsService.getReferralsByUserId(userId);
  }
}
