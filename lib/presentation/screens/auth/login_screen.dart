import 'package:flutter/material.dart';
import 'package:farmer_procurement_app/core/constants/app_colors.dart';
import 'package:farmer_procurement_app/core/localization/app_translations.dart';
import 'package:farmer_procurement_app/data/procurement_repository.dart';
import 'package:farmer_procurement_app/presentation/screens/home/main_nav_scaffold.dart';
import 'package:farmer_procurement_app/presentation/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final text = _mobileController.text.trim();
    if (text.length < 10) {
      setState(() {
        _errorMessage = ProcurementRepository().isTamil
            ? 'சரியான 10 இலக்க கைபேசி எண்ணை உள்ளிடவும்'
            : 'Please enter a valid 10-digit mobile number';
      });
      return;
    }
    setState(() {
      _otpSent = true;
      _errorMessage = null;
      _otpController.text = '1234'; // Pre-fill mock OTP for easy evaluation
    });
  }

  void _verifyAndLogin() {
    final repo = ProcurementRepository();
    final otpText = _otpController.text.trim();
    if (otpText.length < 4) {
      setState(() {
        _errorMessage = repo.isTamil
            ? 'சரியான 4 இலக்க OTP உள்ளிடவும்'
            : 'Please enter a valid 4-digit OTP';
      });
      return;
    }
    repo.login(_mobileController.text.trim());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScaffold()),
    );
  }

  void _useDemoAccount() {
    final repo = ProcurementRepository();
    _mobileController.text = repo.currentFarmer.mobileNumber;
    _sendOtp();
    _verifyAndLogin();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProcurementRepository();

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final lang = repo.language;
        final isTamil = repo.isTamil;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(AppTranslations.text('farmer_login', lang)),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isTamil ? 'English' : 'தமிழ்',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () => repo.toggleLanguage(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // Emblematical banner
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 58,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    AppTranslations.text('app_title', lang),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    AppTranslations.text('app_subtitle', lang),
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Mobile Number Card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_android_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppTranslations.text('enter_mobile', lang),
                              style: const TextStyle(
                                fontSize: 17.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🇮🇳 +91 ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: AppColors.divider,
                                  ),
                                ],
                              ),
                            ),
                            hintText: '98765 43210',
                            counterText: '',
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        if (!_otpSent)
                          ElevatedButton.icon(
                            onPressed: _sendOtp,
                            icon: const Icon(Icons.send_rounded),
                            label: Text(AppTranslations.text('send_otp', lang)),
                          )
                        else ...[
                          Text(
                            AppTranslations.text('enter_otp', lang),
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 10,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: '1 2 3 4',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _verifyAndLogin,
                            icon: const Icon(Icons.verified_user_rounded),
                            label: Text(
                              AppTranslations.text('verify_login', lang),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Fast Demo Account Button (For SIH presentation)
                OutlinedButton.icon(
                  onPressed: _useDemoAccount,
                  icon: const Icon(
                    Icons.flash_on_rounded,
                    color: AppColors.secondary,
                  ),
                  label: Text(
                    AppTranslations.text('use_demo_account', lang),
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                    backgroundColor: AppColors.secondaryContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Register Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    AppTranslations.text('new_farmer_register', lang),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
