import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:projecho/screens/userSettings.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final String displayName = "Anonymous";
  final String email = "anonymous@projecho.app";
  final String phoneNumber = "";
  final String bio = "Your privacy is respected.";
  final String avatarPath = 'assets/anonymous.png'; // Use your own anonymous image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blue[50],
                  backgroundImage: AssetImage(avatarPath),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bio,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              label: 'Edit Profile',
              onTap: () {
                // Navigate to Edit Profile screen
              },
            ),
            _buildOptionTile(
              icon: FontAwesome.gear,
              label: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSettings()),
                );
              },
            ),
            _buildOptionTile(
              icon: FontAwesome.sign_out,
              label: 'Logout',
              color: Colors.red[400],
              onTap: () {
                // Perform logout
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "v1.0.0 • ECHO",
                style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, size: 20, color: color ?? Colors.indigo),
          title: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}
