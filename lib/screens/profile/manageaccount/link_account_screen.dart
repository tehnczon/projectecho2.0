import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/form/plhivForm/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projecho/login/signup/privacyPolicy.dart';
import 'package:projecho/login/signup/terms.dart';

class AccountLinkingPage extends StatefulWidget {
  const AccountLinkingPage({super.key});

  @override
  _AccountLinkingPageState createState() => _AccountLinkingPageState();
}

class _AccountLinkingPageState extends State<AccountLinkingPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _isScrolled = false;
  bool _isLoading = true;

  // Account status
  bool _hasGoogleLinked = false;
  bool _hasPhoneLinked = false;
  String? _linkedEmail;
  String? _linkedPhone;
  String? _googlePhotoUrl;
  String? _googleDisplayName;

  // Phone verification
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isVerifying = false;
  bool _otpSent = false;
  int _resendTimer = 0;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkLinkedAccounts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isScrolled = _scrollOffset > 100;
    });
  }

  Future<void> _checkLinkedAccounts() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check linked providers
      for (var info in user.providerData) {
        if (info.providerId == 'google.com') {
          setState(() {
            _hasGoogleLinked = true;
            _linkedEmail = info.email;
            _googlePhotoUrl = info.photoURL;
            _googleDisplayName = info.displayName;
          });
        } else if (info.providerId == 'phone') {
          setState(() {
            _hasPhoneLinked = true;
            _linkedPhone = info.phoneNumber;
          });
        }
      }
    } catch (e) {
      print('Error checking linked accounts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _linkGoogleAccount() async {
    try {
      HapticFeedback.mediumImpact();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your 10-digit mobile number',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Linking Google Account...',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
      );

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the credential
      final user = FirebaseAuth.instance.currentUser;
      await user?.linkWithCredential(credential);

      Navigator.pop(context);

      await _checkLinkedAccounts();

      _showSuccessSnackBar('Google account linked successfully!');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      if (e.code == 'provider-already-linked') {
        _showErrorSnackBar('This Google account is already linked.');
      } else if (e.code == 'credential-already-in-use') {
        _showErrorSnackBar(
          'This Google account is already used by another user.',
        );
      } else {
        _showErrorSnackBar('Failed to link Google account: ${e.message}');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('An error occurred. Please try again.');
    }
  }

  Future<void> _unlinkGoogleAccount() async {
    final confirmed = await _showConfirmDialog(
      title: 'Unlink Google Account',
      message:
          'Are you sure you want to unlink your Google account? You can link it again later.',
      confirmText: 'Unlink',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      HapticFeedback.mediumImpact();

      final user = FirebaseAuth.instance.currentUser;
      await user?.unlink('google.com');

      // Sign out from Google
      await _googleSignIn.signOut();

      await _checkLinkedAccounts();

      _showSuccessSnackBar('Google account unlinked successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to unlink Google account.');
    }
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showErrorSnackBar('Please enter a phone number');
      return;
    }

    // Validate phone format (must be exactly 10 digits)
    if (phone.length != 10) {
      _showErrorSnackBar('Please enter a valid 10-digit phone number');
      return;
    }

    // Validate it starts with 9 (Philippine mobile numbers)
    if (!phone.startsWith('9')) {
      _showErrorSnackBar('Philippine mobile numbers must start with 9');
      return;
    }

    // Construct full phone number with country code
    final fullPhoneNumber = '+63$phone';

    setState(() => _isVerifying = true);
    HapticFeedback.lightImpact();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _linkPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isVerifying = false);

          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts. Please try again later.';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again later.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }

          _showErrorSnackBar(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isVerifying = false;
            _resendTimer = 60;
          });

          _startResendTimer();
          _showSuccessSnackBar('OTP sent to +63$phone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _verificationId = verificationId);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isVerifying = false);
      _showErrorSnackBar('Failed to send OTP. Please try again.');
      print('Error sending OTP: $e');
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isVerifying = true);
    HapticFeedback.lightImpact();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _linkPhoneCredential(credential);
    } catch (e) {
      setState(() => _isVerifying = false);
      _showErrorSnackBar('Invalid OTP. Please try again.');
    }
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (_hasPhoneLinked) {
        // Update phone number
        await user?.updatePhoneNumber(credential);
      } else {
        // Link phone number
        await user?.linkWithCredential(credential);
      }

      setState(() {
        _otpSent = false;
        _isVerifying = false;
        _phoneController.clear();
        _otpController.clear();
      });

      await _checkLinkedAccounts();

      _showSuccessSnackBar(
        _hasPhoneLinked
            ? 'Phone number updated successfully!'
            : 'Phone number linked successfully!',
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isVerifying = false);

      if (e.code == 'provider-already-linked') {
        _showErrorSnackBar('A phone number is already linked.');
      } else if (e.code == 'credential-already-in-use') {
        _showErrorSnackBar(
          'This phone number is already used by another user.',
        );
      } else {
        _showErrorSnackBar('Failed to link phone number: ${e.message}');
      }
    }
  }

  Future<void> _unlinkPhone() async {
    // Check if user has at least one other sign-in method
    final user = FirebaseAuth.instance.currentUser;
    if (user?.providerData.length == 1) {
      _showErrorSnackBar(
        'Cannot unlink. You need at least one sign-in method.',
      );
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Unlink Phone Number',
      message: 'Are you sure you want to unlink your phone number?',
      confirmText: 'Unlink',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      HapticFeedback.mediumImpact();
      await user?.unlink('phone');
      await _checkLinkedAccounts();
      _showSuccessSnackBar('Phone number unlinked successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to unlink phone number.');
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDestructive ? Colors.red : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildAccountCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLinked,
    required VoidCallback onTap,
    String? photoUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isLinked ? AppColors.primary.withOpacity(0.3) : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isLinked
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      photoUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photoUrl,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Icon(
                            icon,
                            color:
                                isLinked ? AppColors.primary : Colors.grey[600],
                            size: 24,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isLinked
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isLinked ? 'Linked' : 'Not Linked',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLinked ? Colors.green : Colors.orange,
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

  Widget _buildPhoneSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasPhoneLinked ? 'Change Phone Number' : 'Link Phone Number',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (!_otpSent) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Country Code Prefix
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇵🇭', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '+63',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Phone Number Input
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: '9171234567',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      counterText: '',
                      prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isVerifying
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Send OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'OTP sent to +63${_phoneController.text}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '******',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isVerifying
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Verify OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: _resendTimer > 0 ? null : _sendOTP,
                child: Text(
                  _resendTimer > 0
                      ? 'Resend OTP in $_resendTimer s'
                      : 'Resend OTP',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        _resendTimer > 0
                            ? AppColors.textSecondary
                            : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (!_isScrolled)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Image.asset(
                  'assets/account_link.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 250,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Linked Accounts',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your sign-in methods and security',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else ...[
                      _buildAccountCard(
                        title: 'Google Account',
                        subtitle:
                            _hasGoogleLinked
                                ? (_linkedEmail ?? 'Linked')
                                : 'Sign in with Google',
                        icon: Icons.g_mobiledata,
                        isLinked: _hasGoogleLinked,
                        photoUrl: _googlePhotoUrl,
                        onTap:
                            _hasGoogleLinked
                                ? _unlinkGoogleAccount
                                : _linkGoogleAccount,
                      ),

                      _buildAccountCard(
                        title: 'Phone Number',
                        subtitle:
                            _hasPhoneLinked
                                ? (_linkedPhone ?? 'Linked')
                                : 'Verify with OTP',
                        icon: Icons.phone,
                        isLinked: _hasPhoneLinked,
                        onTap: () {
                          // Scroll to phone section or show modal
                          if (_hasPhoneLinked) {
                            _unlinkPhone();
                          }
                        },
                      ),

                      if (!_hasPhoneLinked || true) ...[
                        const SizedBox(height: 24),
                        _buildPhoneSection(),
                      ],

                      const SizedBox(height: 40),

                      // Security Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.security,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Security',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Linking multiple sign-in methods helps secure your account and makes it easier to recover if you forget your password.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms and Privacy
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "By continuing, you agree to our ",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Terms(),
                                ),
                              );
                            },
                            child: Text(
                              "Terms ",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            "and have read our ",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Privacypolicy(),
                                ),
                              );
                            },
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
