class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final DateTime createdAt;
  final String referralCode;
  final String? referredBy;
  final String? upiId;
  final String? bankName;
  final bool isDepositActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.createdAt,
    required this.referralCode,
    this.referredBy,
    this.upiId,
    this.bankName,
    this.isDepositActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'referralCode': referralCode,
      'referredBy': referredBy,
      'upiId': upiId,
      'bankName': bankName,
      'isDepositActive': isDepositActive,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      referralCode: json['referralCode'],
      referredBy: json['referredBy'],
      upiId: json['upiId'],
      bankName: json['bankName'],
      isDepositActive: json['isDepositActive'] ?? false,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? upiId,
    String? bankName,
    bool? isDepositActive,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      referralCode: referralCode,
      referredBy: referredBy,
      upiId: upiId ?? this.upiId,
      bankName: bankName ?? this.bankName,
      isDepositActive: isDepositActive ?? this.isDepositActive,
    );
  }
}
