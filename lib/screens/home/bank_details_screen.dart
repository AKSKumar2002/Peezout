import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountHolderController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _bankNameController;
  late TextEditingController _branchController;
  late TextEditingController _upiIdController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _accountHolderController = TextEditingController(text: user?.name ?? '');
    _accountNumberController = TextEditingController();
    _ifscCodeController = TextEditingController();
    _bankNameController = TextEditingController(text: user?.bankName ?? '');
    _branchController = TextEditingController();
    _upiIdController = TextEditingController(text: user?.upiId ?? '');
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _saveBankDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    await authProvider.updateProfile(
      upiId: _upiIdController.text.trim(),
      bankName: _bankNameController.text.trim(),
      // Note: We'll store additional bank details in a future update
      // For now, we're using the existing upiId and bankName fields
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bank Details Saved Successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Bank Details", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.vividGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.vividGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.vividGold, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your bank details are securely saved and will be used for withdrawals.',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section: Bank Account Details
                  Text(
                    'BANK ACCOUNT DETAILS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.vividGold,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _accountHolderController,
                    label: "Account Holder Name",
                    hint: "Enter name as per bank account",
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Account holder name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _accountNumberController,
                    label: "Account Number",
                    hint: "Enter your account number",
                    prefixIcon: Icons.account_balance,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return "Account number is required";
                      if (v.length < 9 || v.length > 18) return "Invalid account number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _ifscCodeController,
                    label: "IFSC Code",
                    hint: "e.g., SBIN0001234",
                    prefixIcon: Icons.account_balance_outlined,
                    validator: (v) {
                      if (v!.isEmpty) return "IFSC code is required";
                      if (v.length != 11) return "IFSC code must be 11 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _bankNameController,
                    label: "Bank Name",
                    hint: "e.g., State Bank of India",
                    prefixIcon: Icons.business,
                    validator: (v) => v!.isEmpty ? "Bank name is required" : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _branchController,
                    label: "Branch Name",
                    hint: "Enter branch name",
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => v!.isEmpty ? "Branch name is required" : null,
                  ),

                  const SizedBox(height: 32),

                  // Section: UPI Details
                  Text(
                    'UPI DETAILS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.vividGold,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _upiIdController,
                    label: "UPI ID",
                    hint: "username@upi",
                    prefixIcon: Icons.payment_outlined,
                    validator: (v) {
                      if (v!.isEmpty) return "UPI ID is required";
                      if (!v.contains('@')) return "Invalid UPI ID format";
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  GradientButton(
                    onPressed: _isLoading ? null : _saveBankDetails,
                    gradient: AppTheme.goldGradient,
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text(
                            "Save Bank Details",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
