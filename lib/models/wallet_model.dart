enum TransactionType { deposit, withdrawal, referralBonus, gameReward }

enum TransactionStatus { pending, completed, failed }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String? description;
  final String? referenceId;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    this.description,
    this.referenceId,
  });

  String get typeString {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.referralBonus:
        return 'Referral Bonus';
      case TransactionType.gameReward:
        return 'Game Reward';
    }
  }

  String get statusString {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status.toString(),
      'description': description,
      'referenceId': referenceId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      description: json['description'],
      referenceId: json['referenceId'],
    );
  }
}

class WalletModel {
  final double depositBalance;
  final double earningsBalance;
  final double totalEarnings;
  final List<Transaction> transactions;

  WalletModel({
    required this.depositBalance,
    required this.earningsBalance,
    required this.totalEarnings,
    required this.transactions,
  });

  double get totalBalance => depositBalance + earningsBalance;

  Map<String, dynamic> toJson() {
    return {
      'depositBalance': depositBalance,
      'earningsBalance': earningsBalance,
      'totalEarnings': totalEarnings,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      depositBalance: json['depositBalance'],
      earningsBalance: json['earningsBalance'],
      totalEarnings: json['totalEarnings'],
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
    );
  }
}
