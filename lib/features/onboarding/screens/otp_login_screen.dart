import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/constants/app_constants.dart';

class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _e164Phone => '+91${_phoneController.text.trim()}';

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(firebaseAuthServiceProvider);

    await authService.sendOtp(
      phoneNumber: _e164Phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpSent = true;
          _verificationId = verificationId;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _otpFocusNodes[0].requestFocus();
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
      },
      onAutoVerified: (authResult) {
        // Android auto-read the SMS — navigate directly.
        if (!mounted) return;
        _handleAuthSuccess(authResult.isNewUser);
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit OTP.');
      return;
    }
    if (_verificationId == null) {
      setState(() => _errorMessage = 'OTP session expired. Please resend.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final result = await authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: otp,
        phoneNumber: _e164Phone,
      );

      if (!mounted) return;
      _handleAuthSuccess(result.isNewUser);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  void _handleAuthSuccess(bool isNewUser) {
    if (!mounted) return;
    ref.invalidate(currentPatientProvider);
    ref.invalidate(healthTimelineProvider);
    ref.invalidate(prescriptionsProvider);
    ref.invalidate(labReportsProvider);
    ref.invalidate(referralsProvider);
    ref.invalidate(consultationsProvider);
    // GoRouter's redirect will react to the auth state change.
    // For new users, we also persist the flag so the guard routes them correctly.
    if (isNewUser) {
      context.go(AppRoutes.registerContact);
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _resetToPhone() {
    setState(() {
      _otpSent = false;
      _verificationId = null;
      _errorMessage = null;
      for (final c in _otpControllers) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPadding, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  _otpSent ? 'Enter OTP' : 'Enter Your Phone Number',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'We sent a 6-digit code to ${_phoneController.text}'
                      : 'We will send you a one-time password to verify your number.',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
                ),

                const SizedBox(height: 40),

                if (!_otpSent) ...[
                  // Phone number field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    style: AppTextStyles.headlineSmall,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: '98765 43210',
                      prefixText: '+91  ',
                      prefixStyle: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.textMuted),
                      counterText: '',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter your phone number';
                      if (val.length < 10) return 'Enter a valid 10-digit number';
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  RuralCareButton(
                    label: 'Send OTP',
                    onPressed: _sendOtp,
                    isLoading: _isLoading,
                    icon: Icons.sms_outlined,
                  ),
                ] else ...[
                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 48,
                        child: TextFormField(
                          controller: _otpControllers[i],
                          focusNode: _otpFocusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: AppColors.primary),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              _otpFocusNodes[i + 1].requestFocus();
                            } else if (val.isEmpty && i > 0) {
                              _otpFocusNodes[i - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  RuralCareButton(
                    label: 'Verify & Continue',
                    onPressed: _verifyOtp,
                    isLoading: _isLoading,
                    icon: Icons.check_circle_outline,
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: _resetToPhone,
                      child: Text(
                        'Change phone number',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emergency.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.emergency.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: AppColors.emergency),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.emergency),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Emergency access — always visible even before login
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go(AppRoutes.emergency),
                    icon: const Icon(Icons.emergency,
                        size: 16, color: AppColors.emergency),
                    label: Text(
                      'Need emergency help?',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.emergency),
                    ),
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
