// File: lib/features/profile/presentation/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/login/signup/plhivForm/app_colors.dart';
import './services/profile_service.dart';
import './services/auth_service.dart';
import './widgets/profile_header.dart';
import './widgets/basic_info_card.dart';
import './widgets/sensitive_info_section.dart';
import './widgets/quick_actions_card.dart';
import 'package:projecho/screens/profile/edit profile/edit_profile.dart';
import 'package:projecho/screens/profile/manageaccount/link_account_screen.dart';
import 'package:projecho/login/login/inputNum.dart';
import 'package:projecho/static/privacyPolicy.dart';
import 'package:projecho/static/terms.dart';
import 'package:projecho/screens/profile/support.dart';
import 'package:projecho/screens/profile/userSettings.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  String displayName = "Anonymous";
  bool showSensitive = false;
  bool isAuthenticated = false;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? secureUserData;

  double _scrollOffset = 0.0;
  bool _isScrolled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isScrolled = _scrollOffset > 100;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final data = await _profileService.loadBaseUserData();

    setState(() {
      userData = data;
      displayName = data?['generatedUIC'] ?? 'Anonymous';
      _isLoading = false;
    });
  }

  Future<void> _authenticateAndLoadSecureData() async {
    final authenticated = await _authService.authenticateWithBiometrics();

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Authentication failed or not available'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      isAuthenticated = true;
      showSensitive = true;
    });

    final secure = await _profileService.loadSecureUserData();
    setState(() => secureUserData = secure);
  }

  void _handleHideSensitiveData() {
    setState(() {
      showSensitive = false;
      isAuthenticated = false;
      secureUserData = null;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;

    try {
      _showLoadingDialog();
      await _authService.logout();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EnterNumberPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Logout failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.red[400],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to logout?',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You will need to sign in again',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Logging out...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Gradient overlay when not scrolled
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

          // Main content
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : ListView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Profile Header
                  ProfileHeader(
                    displayName: displayName,
                    onEditPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfile()),
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Link Account Button
                  _buildLinkAccountButton(),

                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Basic Information Card
                        BasicInfoCard(userData: userData),

                        const SizedBox(height: 20),

                        // Sensitive Information Section
                        SensitiveInfoSection(
                          userData: userData,
                          secureUserData: secureUserData,
                          showSensitive: showSensitive,
                          isAuthenticated: isAuthenticated,
                          onAuthenticationRequested:
                              _authenticateAndLoadSecureData,
                          onHideRequested: _handleHideSensitiveData,
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions Card
                        QuickActionsCard(
                          onTermsTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Terms()),
                              ),
                          onPrivacyTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Privacypolicy(),
                                ),
                              ),
                          onSupportTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SupportContactPage(),
                                ),
                              ),
                          onSettingsTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdvancedSettingsPage(),
                                ),
                              ),
                        ),

                        const SizedBox(height: 20),

                        // Logout Button
                        _buildLogoutButton(),

                        const SizedBox(height: 30),

                        // Version Info
                        Center(
                          child: Text(
                            "v2.0.0 • ECHO • Secure Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          boxShadow:
              _isScrolled
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: AnimatedOpacity(
            opacity: _isScrolled ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              displayName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: _isScrolled ? Colors.black87 : AppColors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfile()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AccountLinkingPage()),
            ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.manage_accounts_rounded,
                  color: AppColors.surface,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link Account',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Make your account more secure by linking additional methods',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.surface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red[400]),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.red[400],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.red[400],
        ),
        onTap: _handleLogout,
      ),
    );
  }
}
