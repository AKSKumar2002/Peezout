import 'gsheets_export.dart';

class GoogleSheetsService {
  // TODO: Replace with your actual Google Sheets credentials
  // Get credentials from: https://console.cloud.google.com/
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "refferal-based-app",
  "private_key_id": "783696fbc6052f60627fd2ff83e9d64b968fbbe9",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDHR3eLgiUNtcwo\n4tPxfrV5bjptr0XsGitvaHHbLaIts/8EkVHMv6dOAHHStgnguIlCfs8JdTo6+Atu\nWV9+Pevdbbu8/W+aHDCGp5Fb/2JHZNq391Kg5T5ZdtrS7IQZ3hnZ7vvADuAuvO4S\n4q4/UexpHLmsDh6uj1FDYGdoJPBMs41PE4Zyx3rHl3LkvPJS3LUxNSzXNeGjRYiD\ntoFwuaGsaxAVnXXG2MFDMIxRJfMQcYRbE5GmNEFppQ263GgFwkQdpI79iuqFiK+7\nC8QKUmLlFXJ4ii3D8ZQSaY/7C4E2nJL+/l5c/FdR23BhUntfzxF7Fh3EUcQCXwHF\nkR1BC+xpAgMBAAECggEANPYr8dJNWbbywv0BugFkZpjig2sdKLIN0CaQd+FJZF8d\njA+5DzLyWnsoxQjnWCeDJz5/dLKInsp0c0fiZrE7Qdabmg86/Vi3ltnq+mnFq1bF\nADaFachzSSCa6Iq+UwehlDd9Bd6OOy2wEinXiHGT5J2jRPRduCPTw5XX9ag3ixKG\nxhGtljWhb8YiZkY+5SqaxJ0omho41XYoFN/COahod+szCGxSq3YX9WJchfWmSeSZ\nFjJhZvPi1K+/akcuWufHtlDTy4WNtS6AWojK93eugfnIQnEgBOtKHBuNEbrkRT0Y\n1aQ53WAMOSaacwwNx3VY4XqjHH0p7k9WEQxJOSd45wKBgQDyRkCShWu388iULKTr\nstLexMrqcMSY9ZuJqbHAr24Th7TYWt3ZROrvBOqh9xFV3xKYX6awh6MUlT1opOkf\nhfpQZk6dFNTiA18AsNo8Rj7F8V3AjAZ0Noel4rr6rfcnK/9POC3r3ILMASDJqZbd\naDBAnLR93j/Z3D2QVOxvtVlu+wKBgQDSkaWqm8oaZCtgM4Y8PKTmp3FZEVoRzv3Y\nnz6BuXlSkXOSKeNzYtbR/mQ5ShRRAYBjnk63yLwU07hi1bJ8WDZh9qGoy/ba0vQy\nnVMDFaIDgQiB+8escPYnqev1ePBA9wnpB0zbc1BrCxQX9meOIVD8WPYUOv18XRjC\nLVRIsntk6wKBgAGstKOOooj5+Wf0ywsKCGUbzR9DukgoYnPYJW9khwlBheF8902a\nKVmPmiOWdps2WIWPG7LarSjmQy9m/GmIXouRuXdifno1dcGmd0u1XJe3rGM5VI4X\nFmbyI0K6UxwFNNWSWNbphknstBJQxscvAi5gJus7zwstd4t42s2G3mBjAoGATjNf\nFjxjU2fOIB0ihi5zg2G+G7jw/VolNhT17tGF+B8ij67U1N5pL3XNnOUhJHBtURHS\n5Dg9eXKjsLjyX3GXSMyCfyC4nc3oeP+qe6PGFo0OLs/l+Om+0T4u7mwqtcXJPWzD\no2BxBkAIB1owXT2MSRt00FCUIWKltj+FZLY8U18CgYEAvnN6BSboOQXLESthMvqw\nSmBE8SBquN/0fywOjBPBu+nxHilvuuHzb9EHymBZ4vkpSubEmVdFm+lrFE3Eqfj/\nGLZeoehsfvurh6/j3SPpW2W2/KwGQxahDH5yJRLS65ClGHHZMlT8Pcvrt5uZCEVl\nRQcgSzVicd3gaBA1AdF18ek=\n-----END PRIVATE KEY-----\n",
  "client_email": "referral-app-sheets@refferal-based-app.iam.gserviceaccount.com",
  "client_id": "103263448292985426743",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/referral-app-sheets%40refferal-based-app.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

  // TODO: Replace with your actual Google Sheets spreadsheet ID
  static const _spreadsheetId = '1-qsjML82bDfNa0cppLlKOidMJagoVAfEmEyisbfJE54';

  GSheets? _gsheets;
  Spreadsheet? _spreadsheet;
  Worksheet? _usersSheet;
  Worksheet? _referralsSheet;
  Worksheet? _depositsSheet;

  static final GoogleSheetsService _instance = GoogleSheetsService._internal();
  factory GoogleSheetsService() => _instance;

  GoogleSheetsService._internal() {
    _gsheets = GSheets(_credentials);
  }

  // Initialize the sheets
  Future<void> initialize() async {
    
    try {
      _spreadsheet = await _gsheets?.spreadsheet(_spreadsheetId);
      
      // Get or create Users sheet
      _usersSheet = _spreadsheet?.worksheetByTitle('Users');
      if (_usersSheet == null) {
        _usersSheet = await _spreadsheet?.addWorksheet('Users');
        await _usersSheet?.values.insertRow(1, [
          'User ID',
          'Name',
          'Email',
          'Phone',
          'Referral Code',
          'Referred By',
          'UPI ID',
          'Bank Name',
          'Created At',
          'Is Deposit Active'
        ]);
      }

      // Get or create Referrals sheet
      _referralsSheet = _spreadsheet?.worksheetByTitle('Referrals');
      if (_referralsSheet == null) {
        _referralsSheet = await _spreadsheet?.addWorksheet('Referrals');
        await _referralsSheet?.values.insertRow(1, [
          'Referrer User ID',
          'Referrer Name',
          'Referred User ID',
          'Referred User Name',
          'Referred User Email',
          'Referred User Phone',
          'Join Date',
          'Deposit Amount',
          'Commission Earned',
          'Level'
        ]);
      }

      // Get or create Deposits sheet
      _depositsSheet = _spreadsheet?.worksheetByTitle('Deposits');
      if (_depositsSheet == null) {
        _depositsSheet = await _spreadsheet?.addWorksheet('Deposits');
        await _depositsSheet?.values.insertRow(1, [
          'User ID',
          'User Name',
          'Amount',
          'Timestamp',
          'Referrer User ID',
          'Commission Paid'
        ]);
      }
    } catch (e) {
      print('Error initializing Google Sheets: $e');
      // Continue without sheets if there's initialization error
    }
  }

  // Save user to Google Sheets
  Future<void> saveUser({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String referralCode,
    String? referredBy,
    String? upiId,
    String? bankName,
    required DateTime createdAt,
    required bool isDepositActive,
  }) async {
    try {
      await initialize();
      await _usersSheet?.values.appendRow([
        userId,
        name,
        email,
        phone,
        referralCode,
        referredBy ?? '',
        upiId ?? '',
        bankName ?? '',
        createdAt.toIso8601String(),
        isDepositActive ? 'YES' : 'NO',
      ]);
    } catch (e) {
      print('Error saving user to Google Sheets: $e');
    }
  }

  // Update user profile in Google Sheets
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? upiId,
    String? bankName,
  }) async {
    try {
      await initialize();
      
      // Find the row with this user ID
      final allRows = await _usersSheet?.values.allRows();
      if (allRows == null) return;

      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i][0] == userId) {
          final row = i + 1;
          
          // Update specific columns
          if (name != null) {
            await _usersSheet?.values.insertValue(name, column: 2, row: row);
          }
          if (email != null) {
            await _usersSheet?.values.insertValue(email, column: 3, row: row);
          }
          if (phone != null) {
            await _usersSheet?.values.insertValue(phone, column: 4, row: row);
          }
          if (upiId != null) {
            await _usersSheet?.values.insertValue(upiId, column: 7, row: row);
          }
          if (bankName != null) {
            await _usersSheet?.values.insertValue(bankName, column: 8, row: row);
          }
          break;
        }
      }
    } catch (e) {
      print('Error updating user profile in Google Sheets: $e');
    }
  }

  // Update deposit status
  Future<void> updateDepositStatus({
    required String userId,
    required bool isDepositActive,
  }) async {
    try {
      await initialize();
      
      final allRows = await _usersSheet?.values.allRows();
      if (allRows == null) return;

      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i][0] == userId) {
          final row = i + 1;
          await _usersSheet?.values.insertValue(
            isDepositActive ? 'YES' : 'NO',
            column: 10,
            row: row
          );
          break;
        }
      }
    } catch (e) {
      print('Error updating deposit status in Google Sheets: $e');
    }
  }

  // Save referral relationship
  Future<void> saveReferral({
    required String referrerUserId,
    required String referrerName,
    required String referredUserId,
    required String referredUserName,
    required String referredUserEmail,
    required String referredUserPhone,
    required DateTime joinDate,
    required double depositAmount,
    required double commissionEarned,
    required int level,
  }) async {
    try {
      await initialize();
      await _referralsSheet?.values.appendRow([
        referrerUserId,
        referrerName,
        referredUserId,
        referredUserName,
        referredUserEmail,
        referredUserPhone,
        joinDate.toIso8601String(),
        depositAmount.toString(),
        commissionEarned.toString(),
        level.toString(),
      ]);
    } catch (e) {
      print('Error saving referral to Google Sheets: $e');
    }
  }

  // Save deposit transaction
  Future<void> saveDeposit({
    required String userId,
    required String userName,
    required double amount,
    required DateTime timestamp,
    String? referrerUserId,
    double? commissionPaid,
  }) async {
    try {
      await initialize();
      await _depositsSheet?.values.appendRow([
        userId,
        userName,
        amount.toString(),
        timestamp.toIso8601String(),
        referrerUserId ?? '',
        commissionPaid?.toString() ?? '0',
      ]);
    } catch (e) {
      print('Error saving deposit to Google Sheets: $e');
    }
  }

  // Get user by referral code
  Future<Map<String, dynamic>?> getUserByReferralCode(String referralCode) async {
    try {
      await initialize();
      
      final allRows = await _usersSheet?.values.allRows();
      if (allRows == null) return null;

      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i][4] == referralCode) { // Column 5 is referral code
          return {
            'userId': allRows[i][0],
            'name': allRows[i][1],
            'email': allRows[i][2],
            'phone': allRows[i][3],
            'referralCode': allRows[i][4],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting user by referral code: $e');
      return null;
    }
  }

  // Get all referrals for a user
  Future<List<Map<String, dynamic>>> getReferralsByUserId(String userId) async {
    try {
      await initialize();
      
      final allRows = await _referralsSheet?.values.allRows();
      if (allRows == null) return [];

      final referrals = <Map<String, dynamic>>[];
      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i][0] == userId) { // Column 1 is referrer user ID
          referrals.add({
            'referredUserId': allRows[i][2],
            'referredUserName': allRows[i][3],
            'referredUserEmail': allRows[i][4],
            'referredUserPhone': allRows[i][5],
            'joinDate': allRows[i][6],
            'depositAmount': double.tryParse(allRows[i][7]) ?? 0.0,
            'commissionEarned': double.tryParse(allRows[i][8]) ?? 0.0,
            'level': int.tryParse(allRows[i][9]) ?? 1,
          });
        }
      }
      return referrals;
    } catch (e) {
      print('Error getting referrals: $e');
      return [];
    }
  }
}
