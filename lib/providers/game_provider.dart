import 'package:flutter/material.dart';
import 'dart:math';

enum GameType { spinWheel, puzzle, memoryMatch }

class GameProvider with ChangeNotifier {
  int _gamesCompleted = 0;
  double _totalGameEarnings = 0;
  Map<GameType, int> _gameScores = {
    GameType.spinWheel: 0,
    GameType.puzzle: 0,
    GameType.memoryMatch: 0,
  };

  int get gamesCompleted => _gamesCompleted;
  double get totalGameEarnings => _totalGameEarnings;
  Map<GameType, int> get gameScores => _gameScores;

  bool get allGamesCompleted => _gamesCompleted >= 3;

  // Reset for new level
  void resetGames() {
    _gamesCompleted = 0;
    notifyListeners();
  }

  // Play spin wheel
  Future<double> playSpinWheel() async {
    // Simulate spinning
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final rewards = [10.0, 20.0, 50.0, 75.0, 100.0, 150.0, 200.0, 500.0];
    final reward = rewards[random.nextInt(rewards.length)];

    _gameScores[GameType.spinWheel] = reward.toInt();
    _gamesCompleted++;
    _totalGameEarnings += reward;
    notifyListeners();

    return reward;
  }

  // Complete puzzle game
  Future<double> completePuzzle(int moves, int timeSeconds) async {
    // Calculate reward based on performance
    double reward = 100.0;
    
    if (moves < 20) reward += 50.0;
    if (timeSeconds < 60) reward += 50.0;

    _gameScores[GameType.puzzle] = reward.toInt();
    _gamesCompleted++;
    _totalGameEarnings += reward;
    notifyListeners();

    return reward;
  }

  // Complete memory match game
  Future<double> completeMemoryMatch(int matches, int attempts) async {
    // Calculate reward based on accuracy
    final accuracy = matches / attempts;
    double reward = 50.0;
    
    if (accuracy > 0.8) reward += 100.0;
    else if (accuracy > 0.6) reward += 50.0;

    _gameScores[GameType.memoryMatch] = reward.toInt();
    _gamesCompleted++;
    _totalGameEarnings += reward;
    notifyListeners();

    return reward;
  }

  // Get game name
  String getGameName(GameType type) {
    switch (type) {
      case GameType.spinWheel:
        return 'Spin the Wheel';
      case GameType.puzzle:
        return 'Puzzle Challenge';
      case GameType.memoryMatch:
        return 'Memory Match';
    }
  }

  // Check if specific game is completed
  bool isGameCompleted(GameType type) {
    return _gameScores[type]! > 0;
  }
}
