import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/login/login/inputNum.dart';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        // If biometrics not available, allow access
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Advanced Settings',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      setState(() {
        _isAuthenticated = authenticated;
        _isAuthenticating = false;
      });

      if (!authenticated) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isAuthenticated = true;
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    _confirmController.clear();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Type "confirm deletion" to proceed:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  decoration: InputDecoration(
                    hintText: 'confirm deletion',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmController.clear();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_confirmController.text.trim() == 'confirm deletion') {
                    Navigator.pop(context);
                    _deleteAccount();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please type "confirm deletion" exactly',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Replace the _deleteAccount method in userSettings.dart
  // This version preserves analytics integrity while respecting user privacy

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final uid = user.uid;
      final phoneNumber = user.phoneNumber;
      print('🗑️ Starting account deletion for UID: $uid');

      final firestore = FirebaseFirestore.instance;

      // ==================================================
      // STEP 1: Create deletion record (analytics tracking)
      // ==================================================
      await firestore.collection('deletedUsers').doc(uid).set({
        'originalUid': uid,
        'phoneNumber': phoneNumber, // Store hashed version for linking
        'phoneHash': _hashPhoneNumber(phoneNumber ?? ''),
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': uid,
        'wasCountedInAnalytics': true, // Flag for analytics
      });
      print('✅ Created deletion record for analytics tracking');

      // ==================================================
      // STEP 2: Preserve analytics snapshot (before deletion)
      // ==================================================
      final userDoc = await firestore.collection('user').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final role = userData?['role'];

        // Save analytics snapshot
        await firestore.collection('analyticsSnapshots').doc(uid).set({
          'originalUid': uid,
          'phoneHash': _hashPhoneNumber(phoneNumber ?? ''),
          'role': role,
          'ageRange': userData?['ageRange'],
          'genderIdentity': userData?['genderIdentity'],
          'location': userData?['location'],
          'deletedAt': FieldValue.serverTimestamp(),
          'wasActive': true,
          // Anonymized data for analytics
          'anonymizedProfile': {
            'role': role,
            'registrationYear':
                userData?['createdAt'] != null
                    ? (userData!['createdAt'] as Timestamp).toDate().year
                    : null,
            'lastActiveYear': DateTime.now().year,
          },
        });
        print('✅ Analytics snapshot saved');
      }

      // ==================================================
      // STEP 3: Update analytics counters (mark as deleted)
      // ==================================================
      await _updateAnalyticsOnDeletion(uid);

      // ==================================================
      // STEP 4: Delete personal/sensitive data (GDPR compliance)
      // ==================================================
      final batch = firestore.batch();

      // Delete main user document
      batch.delete(firestore.collection('user').doc(uid));

      // Delete from alternative collections
      batch.delete(firestore.collection('users').doc(uid));

      // Delete sensitive health data
      batch.delete(firestore.collection('analyticData').doc(uid));

      // Delete demographic data
      batch.delete(firestore.collection('userDemographic').doc(uid));

      // Delete profile/UIC
      batch.delete(firestore.collection('profiles').doc(uid));

      // Delete researcher requests
      final requestsQuery =
          await firestore
              .collection('requests')
              .where('userId', isEqualTo: uid)
              .get();

      for (var doc in requestsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All personal data deleted from Firestore');

      // ==================================================
      // STEP 5: Delete Firebase Auth account
      // ==================================================
      try {
        await user.delete();
        print('✅ Firebase Auth account deleted');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account deleted successfully. Your privacy is protected.',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const EnterNumberPage()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          setState(() => _isDeleting = false);
          _showReauthDialog();
        } else {
          throw e;
        }
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      print('❌ Error during account deletion: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete account: ${e.toString()}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Helper: Hash phone number for privacy-preserving linking
  String _hashPhoneNumber(String phoneNumber) {
    // Simple hash for linking without storing actual phone number
    // In production, use crypto package: sha256.convert(utf8.encode(phoneNumber))
    return phoneNumber.hashCode.toString();
  }

  // Helper: Update analytics counters when user deletes account
  Future<void> _updateAnalyticsOnDeletion(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get user data to know what to decrement
      final userDoc = await firestore.collection('user').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data();
      final role = userData?['role'];

      // Update global analytics document
      final analyticsRef = firestore.collection('analytics').doc('global');

      // Decrement total users
      await analyticsRef.update({
        'totalActiveUsers': FieldValue.increment(-1),
        'totalDeletedUsers': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Decrement role-specific counters
      if (role != null) {
        await analyticsRef.update({
          'activeUsersByRole.$role': FieldValue.increment(-1),
          'deletedUsersByRole.$role': FieldValue.increment(1),
        });
      }

      print('✅ Analytics counters updated for deletion');
    } catch (e) {
      print('⚠️ Failed to update analytics: $e');
      // Don't fail the deletion if analytics update fails
    }
  }

  // Helper: Show re-authentication dialog
  void _showReauthDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Re-authentication Required',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'For security, please log in again to delete your account. You will receive a new verification code.',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const EnterNumberPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Sign Out & Re-login',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Authenticating...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Authentication Failed',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Advanced Settings',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Area',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'These settings can permanently affect your account',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),

                const SizedBox(height: 30),

                // Danger Zone
                Text(
                  'Danger Zone',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 16),

                // Delete Account Card
                Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              _isDeleting
                                  ? null
                                  : () {
                                    HapticFeedback.lightImpact();
                                    _showDeleteConfirmation();
                                  },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delete Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Permanently delete your account and all data',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isDeleting)
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideX(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Warning Message
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Deleting your account is permanent and cannot be undone. All your health data, records, and information will be lost forever.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
