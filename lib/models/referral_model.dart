class ReferralTask {
  final int level;
  final int requiredReferrals;
  final bool isUnlocked;
  final bool isCompleted;
  final int currentReferrals;
  final bool gamesCompleted;
  final double bonusAmount;

  ReferralTask({
    required this.level,
    required this.requiredReferrals,
    required this.isUnlocked,
    required this.isCompleted,
    required this.currentReferrals,
    required this.gamesCompleted,
    required this.bonusAmount,
  });

  double get progress => currentReferrals / requiredReferrals;

  bool get canPlayGames => currentReferrals >= requiredReferrals && !gamesCompleted;

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'requiredReferrals': requiredReferrals,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'currentReferrals': currentReferrals,
      'gamesCompleted': gamesCompleted,
      'bonusAmount': bonusAmount,
    };
  }

  factory ReferralTask.fromJson(Map<String, dynamic> json) {
    return ReferralTask(
      level: json['level'],
      requiredReferrals: json['requiredReferrals'],
      isUnlocked: json['isUnlocked'],
      isCompleted: json['isCompleted'],
      currentReferrals: json['currentReferrals'],
      gamesCompleted: json['gamesCompleted'],
      bonusAmount: json['bonusAmount'],
    );
  }

  ReferralTask copyWith({
    int? currentReferrals,
    bool? gamesCompleted,
    bool? isCompleted,
  }) {
    return ReferralTask(
      level: level,
      requiredReferrals: requiredReferrals,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      currentReferrals: currentReferrals ?? this.currentReferrals,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      bonusAmount: bonusAmount,
    );
  }
}

class ReferredUser {
  final String id;
  final String name;
  final String? profileImage;
  final DateTime joinedDate;
  final bool hasDeposited;
  final double depositAmount;
  final int level;

  ReferredUser({
    required this.id,
    required this.name,
    this.profileImage,
    required this.joinedDate,
    required this.hasDeposited,
    required this.depositAmount,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'joinedDate': joinedDate.toIso8601String(),
      'hasDeposited': hasDeposited,
      'depositAmount': depositAmount,
      'level': level,
    };
  }

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      id: json['id'],
      name: json['name'],
      profileImage: json['profileImage'],
      joinedDate: DateTime.parse(json['joinedDate']),
      hasDeposited: json['hasDeposited'],
      depositAmount: json['depositAmount'],
      level: json['level'],
    );
  }
}
