import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:projecho/form/plhivForm/app_colors.dart';
import 'package:projecho/screens/profile/userSettings.dart';
import 'package:projecho/login/login/inputNum.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:projecho/login/signup/privacyPolicy.dart';
import 'package:projecho/login/signup/terms.dart';
import 'package:provider/provider.dart';
import 'package:projecho/screens/analytics/components/providers/user_role_provider.dart';
import 'package:projecho/screens/analytics/components/providers/researcher_analytics_provider.dart';
import './support.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String displayName = "Anonymous";
  String bio = "Your privacy is respected.";
  bool showProfile = false;
  bool showSensitive = false;
  bool isAuthenticated = false;
  Map<String, dynamic>? userData;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // 1. Always fetch the base user document
      final userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (!userDoc.exists) {
        print("⚠️ No base user document found for UID: $uid");
        return;
      }

      final baseData = userDoc.data() ?? {};
      final role = baseData['role'];
      print("✅ Role loaded: $role");
      print("📊 Base user data: $baseData");

      // 2. Fetch role-specific extra data
      Map<String, dynamic> extraData = {};

      if (role == 'plhiv') {
        final analyticDoc =
            await FirebaseFirestore.instance
                .collection('analyticData')
                .doc(uid)
                .get();

        if (analyticDoc.exists) {
          extraData = analyticDoc.data() ?? {};
          print("📊 Loaded analyticData for PLHIV: $extraData");
        } else {
          print("⚠️ No analyticData found for UID: $uid");
        }
      } else if (role == 'researcher' || role == 'infoSeeker') {
        final demoDoc =
            await FirebaseFirestore.instance
                .collection('userDemographic')
                .doc(uid)
                .get();

        if (demoDoc.exists) {
          extraData = demoDoc.data() ?? {};
          print("📊 Loaded userDemographic for $role: $extraData");
        } else {
          print("⚠️ No userDemographic found for UID: $uid");
        }
      }

      // 3. Fetch profile doc (for UIC)
      String? generatedUIC;
      final profileDoc =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(uid)
              .get();

      if (profileDoc.exists) {
        generatedUIC = profileDoc.data()?['generatedUIC'];
        print("✅ UIC fetched: $generatedUIC");
      } else {
        print("⚠️ No profile doc found for UID: $uid");
      }

      // 4. Merge all sources
      final combinedData = {
        ...baseData,
        ...extraData,
        if (generatedUIC != null) 'generatedUIC': generatedUIC,
      };

      setState(() {
        userData = combinedData;
        displayName = combinedData['generatedUIC'] ?? 'Anonymous';
      });

      print("✅ Final merged user data: $combinedData");
    } catch (e) {
      print("❌ Failed to load user data: $e");
    }
  }

  Future<void> _authenticateForSensitiveData() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Device security not available. Please enable screen lock in your device settings.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to view sensitive health information',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // This allows PIN/Pattern/Password as fallback
        ),
      );

      if (authenticated) {
        setState(() {
          isAuthenticated = true;
          showSensitive = true;
        });
      }
    } catch (e) {
      print('Authentication error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String enteredPin = '';
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your PIN to view sensitive information'),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit PIN',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => enteredPin = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // In a real app, verify the PIN here
                if (enteredPin.length == 6) {
                  Navigator.pop(context);
                  setState(() {
                    isAuthenticated = true;
                    showSensitive = true;
                  });
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Reset providers first
                  Provider.of<UserRoleProvider>(context, listen: false).reset();
                  Provider.of<ResearcherAnalyticsProvider>(
                    context,
                    listen: false,
                  ).reset();

                  Navigator.pop(context);

                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EnterNumberPage()),
                  );
                },

                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget profileItem(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLocation() {
    if (userData == null) return '';
    final city = userData!['city'] ?? '';
    final barangay = userData!['barangay'] ?? '';

    if (city.isEmpty && barangay.isEmpty) return '';
    if (city.isEmpty) return barangay;
    if (barangay.isEmpty) return city;
    return '$barangay, $city';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),

                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.indigo[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipOval(
                      child: Initicon(
                        text: displayName,
                        backgroundColor: Colors.transparent,
                        size: 100,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ).createShader(bounds),
                    child: Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Basic Information
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Basic Information',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (userData != null) ...[
                      profileItem(
                        "Location",
                        (userData!['location'] is Map &&
                                userData!['location']['city'] != null)
                            ? userData!['location']['city']
                            : _formatLocation(),
                      ),

                      profileItem(
                        "Gender Identity",

                        userData!['genderIdentity'],
                      ),
                    ] else ...[
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sensitive Information
            Container(
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
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.lock_outline,
                    color: showSensitive ? Colors.red : AppColors.primary,
                  ),
                  title: Text(
                    'Sensitive Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    showSensitive ? 'Tap to hide' : 'Requires authentication',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    showSensitive ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onExpansionChanged: (expanding) {
                    if (expanding && !isAuthenticated) {
                      _authenticateForSensitiveData();
                    } else if (!expanding) {
                      setState(() {
                        showSensitive = false;
                        isAuthenticated = false;
                      });
                    }
                  },
                  children: [
                    if (showSensitive && userData != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Confidential Information',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // All other profile data
                              profileItem("User Type", userData!['role']),

                              profileItem("Age Range", userData!['ageRange']),
                              profileItem(
                                "Civil Status",
                                userData!['civilStatus'],
                              ),
                              profileItem(
                                "Education Level",
                                userData!['educationLevel'],
                              ),
                              profileItem(
                                "Nationality",
                                userData!['nationality'],
                              ),

                              profileItem(
                                "Sex Assigned at Birth",
                                userData!['sexAssignedAtBirth'],
                              ),
                              profileItem(
                                "Treatment Hub",
                                userData!['treatmentHub'],
                              ),
                              if (userData!['yearDiagnosed'] != null)
                                profileItem(
                                  "Year Diagnosed",
                                  userData!['yearDiagnosed'].toString(),
                                ),
                              if (userData!['hasHepatitis'] != null)
                                profileItem(
                                  "Has Hepatitis",
                                  userData!['hasHepatitis'] ? 'Yes' : 'No',
                                ),
                              if (userData!['hasTuberculosis'] != null)
                                profileItem(
                                  "Has Tuberculosis",
                                  userData!['hasTuberculosis'] ? 'Yes' : 'No',
                                ),
                              if (userData!['isOFW'] != null)
                                profileItem(
                                  "Is OFW",
                                  userData!['isOFW'] ? 'Yes' : 'No',
                                ),
                              if (userData!['isStudying'] != null)
                                profileItem(
                                  "Is Studying",
                                  userData!['isStudying'] ? 'Yes' : 'No',
                                ),
                              if (userData!['livingWithPartner'] != null)
                                profileItem(
                                  "Living with Partner",
                                  userData!['livingWithPartner'] ? 'Yes' : 'No',
                                ),
                              if (userData!['diagnosedSTI'] != null)
                                profileItem(
                                  "Diagnosed STI",
                                  userData!['diagnosedSTI'] ? 'Yes' : 'No',
                                ),
                              profileItem(
                                "Unprotected Sex With",
                                userData!['unprotectedSexWith'],
                              ),
                              const Divider(height: 24),

                              if (userData!['isPregnant'] != null)
                                profileItem(
                                  "Is Pregnant",
                                  userData!['isPregnant'] ? 'Yes' : 'No',
                                ),
                              if (userData!['motherHadHIV'] != null)
                                profileItem(
                                  "Mother Had HIV",
                                  userData!['motherHadHIV'] ? 'Yes' : 'No',
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick actions
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickAction(
                    icon: Icons.description_outlined,
                    label: 'Terms and Conditions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Terms()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.lock_outline,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Privacypolicy(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.help_outline,
                    label: 'Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SupportContactPage()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.settings_outlined,
                    label: 'Advanced Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdvancedSettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout button
            Container(
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
                    fontSize: 12,
                    color: Colors.red[400],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.red[400],
                ),
                onTap: _showLogoutDialog,
              ),
            ),
            const SizedBox(height: 30),

            // Version info
            Center(
              child: Text(
                "v1.0.0 • ECHO",
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
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
