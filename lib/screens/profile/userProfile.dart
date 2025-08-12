import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:projecho/screens/profile/userSettings.dart';
import 'package:projecho/login/login/inputNum.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:intl/intl.dart';

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

      final phone = user.phoneNumber;

      // Try PLHIV collection first
      final plhivDoc =
          await FirebaseFirestore.instance
              .collection('plhiv_profiles')
              .doc(phone)
              .get();

      if (plhivDoc.exists) {
        setState(() {
          userData = plhivDoc.data();
          displayName = userData?['generatedUIC'] ?? 'Anonymous';
        });
        return;
      }

      // Try researchers collection next
      final researcherDoc =
          await FirebaseFirestore.instance
              .collection('researchers')
              .doc(phone)
              .get();

      if (researcherDoc.exists) {
        setState(() {
          userData = researcherDoc.data();
          displayName = userData?['generatedUIC'] ?? 'Anonymous';
        });
        return;
      }
    } catch (e) {
      print("Failed to load user data: $e");
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
            backgroundColor: Colors.orange,
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildBottomSheetItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to edit profile
                  },
                ),
                _buildBottomSheetItem(
                  icon: Icons.description_outlined,
                  label: 'Terms and Conditions',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to terms
                  },
                ),
                _buildBottomSheetItem(
                  icon: Icons.lock_outline,
                  label: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to privacy policy
                  },
                ),
                _buildBottomSheetItem(
                  icon: Icons.help_outline,
                  label: 'Support',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to support
                  },
                ),
                _buildBottomSheetItem(
                  icon: Icons.settings_outlined,
                  label: 'Advanced',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BiometricAuthPage()),
                    );
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                _buildBottomSheetItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  },
                  isDestructive: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
                onPressed: () {
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
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
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
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

  String _formatBirthDate(dynamic rawDate) {
    if (rawDate == null) return "Not provided";

    // If from Firestore, it's a Timestamp object
    if (rawDate is Timestamp) {
      DateTime date = rawDate.toDate();
      return DateFormat('MMMM d, y').format(date); // e.g., January 1, 2000
    }

    // If already a DateTime
    if (rawDate is DateTime) {
      return DateFormat('MMMM d, y').format(rawDate);
    }

    // If string (ISO8601), parse it
    try {
      DateTime date = DateTime.parse(rawDate.toString());
      return DateFormat('MMMM d, y').format(date);
    } catch (_) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.lato(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () => _showBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile header card
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  // Profile picture
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Edit profile button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       // Navigate to edit profile
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.indigo,
                  //       padding: const EdgeInsets.symmetric(vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       'Edit Profile',
                  //       style: GoogleFonts.lato(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Basic Information
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.indigo,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Basic Information',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (userData != null) ...[
                      profileItem("Location", _formatLocation()),
                      profileItem(
                        "Gender Identity",
                        userData!['genderIdentity'],
                      ),
                      profileItem(
                        "Birth Date",
                        _formatBirthDate(userData!['birthDate']),
                      ),
                      profileItem("User Type", userData!['userType']),
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
                    color: showSensitive ? Colors.red : Colors.orange,
                  ),
                  title: Text(
                    'Sensitive Information',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    showSensitive ? 'Tap to hide' : 'Requires authentication',
                    style: GoogleFonts.lato(
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
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // All other profile data
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
                                "Phone Number",
                                userData!['phoneNumber'],
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
                              profileItem(
                                "Confirmatory Code",
                                userData!['confirmatoryCode'],
                              ),
                              profileItem(
                                "Generated UIC",
                                userData!['generatedUIC'],
                              ),
                              if (userData!['acceptedTerms'] != null)
                                profileItem(
                                  "Accepted Terms",
                                  userData!['acceptedTerms'] ? 'Yes' : 'No',
                                ),
                              profileItem(
                                "Father First Name",
                                userData!['fatherFirstName'],
                              ),
                              profileItem(
                                "Mother First Name",
                                userData!['motherFirstName'],
                              ),
                              if (userData!['birthOrder'] != null)
                                profileItem(
                                  "Birth Order",
                                  userData!['birthOrder'].toString(),
                                ),
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
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickAction(
                    icon: Icons.description_outlined,
                    label: 'Terms and Conditions',
                    onTap: () {},
                  ),
                  _buildQuickAction(
                    icon: Icons.lock_outline,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildQuickAction(
                    icon: Icons.help_outline,
                    label: 'Support',
                    onTap: () {},
                  ),
                  _buildQuickAction(
                    icon: Icons.settings_outlined,
                    label: 'Advanced Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BiometricAuthPage()),
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
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
                style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500]),
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
            Icon(icon, size: 22, color: Colors.indigo),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
