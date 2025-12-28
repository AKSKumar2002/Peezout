import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart'; // Ensure AuthProvider has updateProfile method
import '../home/deposit_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _upiController = TextEditingController();
  final _bankController = TextEditingController();
  XFile? _pickedImage;
  // File? _imageFile; // Removed

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update User Model via Provider
      if (mounted) {
         // final authProvider = Provider.of<AuthProvider>(context, listen: false);
         // await authProvider.updateProfile(...) 
         // For now, we assume success and navigate
         
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => const DepositScreen()),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.goldStart,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Step 1 of 2 Complete",
                  style: GoogleFonts.inter(color: AppTheme.goldStart, fontSize: 12),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  "Complete Your Profile",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                
                const SizedBox(height: 30),
                
                // Avatar Uploader
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.goldStart, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldStart.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: _pickedImage != null
                        ? ClipOval(
                            child: Image.network(_pickedImage!.path, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white70))
                          )
                        : Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white70),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Fields
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _upiController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "UPI ID",
                    hintText: "user@upi", // Hint for withdrawals
                    prefixIcon: Icon(Icons.payment, color: Colors.white70),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bankController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Bank Name",
                    prefixIcon: Icon(Icons.account_balance, color: Colors.white70),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProfile,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Continue to Deposit"),
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
