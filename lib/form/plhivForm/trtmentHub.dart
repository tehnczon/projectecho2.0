import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/registration_flow_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentHubScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const TreatmentHubScreen({super.key, required this.registrationData});

  @override
  State<TreatmentHubScreen> createState() => _TreatmentHubScreenState();
}

class _TreatmentHubScreenState extends State<TreatmentHubScreen> {
  String? _selectedHub;

  Future<List<String>> fetchCenters() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('centers').get();

      final centers =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      if (!centers.contains('Prefer not to share')) {
        centers.insert(0, 'Prefer not to share');
      }

      return centers;
    } catch (e) {
      print("❌ Error fetching centers: $e");
      return [];
    }
  }

  void _onContinue() async {
    if (_selectedHub == null || _selectedHub!.isEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select your treatment hub"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    widget.registrationData.treatmentHub = _selectedHub!;

    bool success = await widget.registrationData.saveToProfiles();
    if (success) {
      RegistrationFlowManager.navigateToNextStep(
        context: context,
        currentStep: 'treatmentHub',
        registrationData: widget.registrationData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 40,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              ),

              const SizedBox(height: 24),

              Text(
                "Your Care Center",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                "Where do you receive your treatment?",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

              const SizedBox(height: 32),

              // Privacy card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.05),
                      AppColors.secondary.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Privacy Matters",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "This helps us connect you with relevant support services. It remains confidential.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

              const SizedBox(height: 24),

              FutureBuilder<List<String>>(
                future: fetchCenters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      "Error loading centers",
                      style: TextStyle(color: AppColors.error),
                    );
                  }

                  final hubs = snapshot.data ?? [];

                  return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,

                          value: _selectedHub,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.local_hospital,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          hint: Text(
                            "Choose from centers",
                            style: TextStyle(color: AppColors.textLight),
                          ),
                          items:
                              hubs.map((hub) {
                                final isPreferNotToShare =
                                    hub.toLowerCase() == 'prefer not to share';
                                return DropdownMenuItem<String>(
                                  value: hub,
                                  child: Text(
                                    hub,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color:
                                          isPreferNotToShare
                                              ? Colors.red
                                              : AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),

                          onChanged: (value) {
                            // your onChanged logic

                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedHub = value;
                            });
                          },
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0);
                },
              ),

              const SizedBox(height: 40),

              // Continue button
              SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // Encouragement message
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.favorite, color: AppColors.success, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        "You're doing great!",
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Every step brings you closer to better support",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 1000.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
