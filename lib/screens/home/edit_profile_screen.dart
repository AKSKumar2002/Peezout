import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _bankController;
  XFile? _pickedImage;
  // File? _imageFile; // Removed in favor of _pickedImage which is cross platform

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _upiController = TextEditingController(text: user?.upiId ?? '');
    _bankController = TextEditingController(text: user?.bankName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      upiId: _upiController.text.trim(),
      bankName: _bankController.text.trim(),
      // In a real app, upload image and get URL. For local demo, we might store path locally or skip.
      profileImage: _pickedImage?.path ?? authProvider.currentUser?.profileImage, 
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Updated Successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current user for existing image
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
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
                children: [
                  // Avatar Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.vividGold, width: 2),
                              boxShadow: AppTheme.glowShadow,
                              color: AppTheme.surface,
                            ),
                              child: ClipOval(
                                child: _pickedImage != null
                                    ? Image.network(_pickedImage!.path, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.white54))
                                    : (user?.profileImage != null && user!.profileImage!.isNotEmpty
                                        ? Image.network(user!.profileImage!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.white54))
                                        : const Icon(Icons.person, size: 60, color: Colors.white54)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.vividGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Fields
                  CustomTextField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "Enter your full name",
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _emailController,
                    label: "Email Address",
                    hint: "Enter your email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? "Email is required" : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    hint: "Enter your phone number",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                     validator: (v) => v!.isEmpty ? "Phone is required" : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _upiController,
                    label: "UPI ID",
                    hint: "username@upi",
                    prefixIcon: Icons.payment_outlined,
                    validator: (v) => v!.isEmpty ? "UPI ID is required" : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _bankController,
                    label: "Bank Name",
                    hint: "Enter your bank name",
                    prefixIcon: Icons.account_balance_outlined,
                    validator: (v) => v!.isEmpty ? "Bank Name is required" : null,
                  ),

                  const SizedBox(height: 40),

                  GradientButton(
                    onPressed: _isLoading ? null : _handleSave,
                    gradient: AppTheme.goldGradient,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Save Changes",
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
