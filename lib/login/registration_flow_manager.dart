// lib/utils/registration_flow_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/signup/UIC.dart';
import 'package:projecho/login/signup/location.dart';
import 'package:projecho/login/signup/genID.dart';
import 'package:projecho/login/signup/userType.dart';
import 'package:projecho/login/signup/plhivForm/yeardiag.dart';
import 'package:projecho/login/signup/plhivForm/trtmentHub.dart';
import 'package:projecho/login/signup/plhivForm/profilingOnbrding_1.dart';
import 'package:projecho/login/signup/plhivForm/mainplhivform.dart';
import 'package:projecho/login/signup/wlcmPrjecho.dart';

class RegistrationFlowManager {
  static const String _progressKey = 'registration_progress';

  // Registration flow steps
  static const Map<String, int> flowSteps = {
    'uic': 0,
    'location': 1,
    'gender': 2,
    'userType': 3,
    // PLHIV specific steps
    'yearDiag': 4,
    'treatmentHub': 5,
    'plhivOnboarding': 6,
    'plhivForm': 7,
    'complete': 8,
    //infoseeker onboarding
  };

  // Save current progress
  static Future<void> saveProgress({
    required String currentStep,
    required RegistrationData registrationData,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = {
        'currentStep': currentStep,
        'stepNumber': flowSteps[currentStep] ?? 0,
        'registrationData': registrationData.toJson(),
        'additionalData': additionalData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0', // Add for compatibility checks
      };

      await prefs.setString(_progressKey, json.encode(progressData));
      print('✅ Progress saved: $currentStep');
    } catch (e) {
      print('❌ Failed to save progress: $e');
    }
  }

  // Load saved progress
  static Future<Map<String, dynamic>?> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);

      if (progressJson != null) {
        final progressData = json.decode(progressJson);

        // Check if progress is recent (within 24 hours)
        final timestamp = DateTime.parse(progressData['timestamp']);
        final hoursSinceProgress = DateTime.now().difference(timestamp).inHours;

        if (hoursSinceProgress > 24) {
          // Clear old progress
          await clearProgress();
          return null;
        }

        return progressData;
      }
    } catch (e) {
      print('❌ Failed to load progress: $e');
    }
    return null;
  }

  // Clear saved progress
  static Future<void> clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
      print('✅ Progress cleared');
    } catch (e) {
      print('❌ Failed to clear progress: $e');
    }
  }

  // Resume registration from saved progress
  static Future<Widget?> resumeRegistration(BuildContext context) async {
    final progress = await loadProgress();
    if (progress == null) return null;

    try {
      final registrationData = RegistrationData.fromJson(
        progress['registrationData'],
      );
      final currentStep = progress['currentStep'] as String;

      // Show resume dialog
      final shouldResume = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.restore, color: Colors.blue, size: 24),
                  SizedBox(width: 8),
                  Text('Resume Registration?'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('We found your incomplete registration from:'),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📍 Step: ${_getStepDisplayName(currentStep)}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '⏰ ${_formatTimestamp(progress['timestamp'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                  child: Text('Start Over'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Resume', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
      );

      if (shouldResume == true) {
        return _getScreenForStep(currentStep, registrationData);
      } else {
        // User chose to start over
        await clearProgress();
        return null;
      }
    } catch (e) {
      print('❌ Error resuming registration: $e');
      await clearProgress();
      return null;
    }
  }

  // Navigate to next step in flow
  static void navigateToNextStep({
    required BuildContext context,
    required String currentStep,
    required RegistrationData registrationData,
    Map<String, dynamic>? additionalData,
  }) async {
    // Save progress before navigation
    await saveProgress(
      currentStep: currentStep,
      registrationData: registrationData,
      additionalData: additionalData,
    );

    final nextStep = _getNextStep(currentStep, registrationData);
    final nextScreen = _getScreenForStep(nextStep, registrationData);

    if (nextScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      ).catchError((error) {
        _handleNavigationError(context, error);
      });
    } else {
      await clearProgress();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    }
  }

  // Navigate to previous step
  static void navigateToPreviousStep({
    required BuildContext context,
    required String currentStep,
    required RegistrationData registrationData,
  }) async {
    final previousStep = _getPreviousStep(currentStep);
    final previousScreen = _getScreenForStep(previousStep, registrationData);

    if (previousScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => previousScreen),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // Get next step based on current step and user type
  static String _getNextStep(String currentStep, RegistrationData data) {
    switch (currentStep) {
      case 'uic':
        return 'location';
      case 'location':
        return 'gender';
      case 'gender':
        return 'userType';
      case 'userType':
        // Branch based on user type
        if (data.userType == 'PLHIV') {
          return 'yearDiag';
        } else {
          return 'complete'; // Info seekers complete here
        }
      case 'yearDiag':
        return 'treatmentHub';
      case 'treatmentHub':
        return 'plhivOnboarding';
      case 'plhivOnboarding':
        return 'plhivForm';
      case 'plhivForm':
        return 'complete';
      default:
        return 'complete';
    }
  }

  // Get previous step
  static String _getPreviousStep(String currentStep) {
    switch (currentStep) {
      case 'location':
        return 'uic';
      case 'gender':
        return 'location';
      case 'userType':
        return 'gender';
      case 'yearDiag':
        return 'userType';
      case 'treatmentHub':
        return 'yearDiag';
      case 'plhivOnboarding':
        return 'treatmentHub';
      case 'plhivForm':
        return 'plhivOnboarding';
      default:
        return 'uic'; // Default to first step
    }
  }

  // Get screen widget for step
  static Widget? _getScreenForStep(String step, RegistrationData data) {
    switch (step) {
      case 'uic':
        return UICScreen(registrationData: data);
      case 'location':
        return LocationScreen(registrationData: data);
      case 'gender':
        return GenderSelectionScreen(registrationData: data);
      case 'userType':
        return UserTypeScreen(registrationData: data);
      case 'yearDiag':
        return YearDiagPage(registrationData: data);
      case 'treatmentHub':
        return TreatmentHubScreen(registrationData: data);
      case 'plhivOnboarding':
        return ProfOnboard1Screen(registrationData: data);
      case 'plhivForm':
        return PLHIVStepperScreen(registrationData: data);
      case 'complete':
        return null; // Handle completion separately
      default:
        return null;
    }
  }

  // Handle navigation errors
  static void _handleNavigationError(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Navigation Error'),
              ],
            ),
            content: Text('Something went wrong. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Handle save errors
  static void _handleSaveError(BuildContext context, String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Save Error'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to save your registration. Your progress has been saved locally.',
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'You can try again later or check your internet connection.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Get display name for step
  static String _getStepDisplayName(String step) {
    switch (step) {
      case 'uic':
        return 'Unique ID Creation';
      case 'location':
        return 'Location Selection';
      case 'gender':
        return 'Gender Identity';
      case 'userType':
        return 'User Type Selection';
      case 'yearDiag':
        return 'Diagnosis Year';
      case 'treatmentHub':
        return 'Treatment Hub';
      case 'plhivOnboarding':
        return 'PLHIV Onboarding';
      case 'plhivForm':
        return 'Health Profile Form';
      default:
        return 'Registration';
    }
  }

  // Format timestamp for display
  static String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  // Validate step completion
  static bool validateStepData(String step, RegistrationData data) {
    switch (step) {
      case 'uic':
        return data.generatedUIC != null && data.birthDate != null;
      case 'location':
        return data.city != null && data.barangay != null;
      case 'gender':
        return data.genderIdentity != null;
      case 'userType':
        return data.userType != null;
      case 'yearDiag':
        return data.yearDiagnosed != null;
      case 'treatmentHub':
        return data.treatmentHub != null;
      case 'plhivOnboarding':
        return true; // Informational step
      case 'plhivForm':
        return data.sexAssignedAtBirth != null &&
            data.ageRange != null &&
            data.nationality != null;
      default:
        return true;
    }
  }

  // Get progress percentage
  static double getProgressPercentage(String currentStep) {
    final stepNumber = flowSteps[currentStep] ?? 0;
    const totalSteps = 11; // Including completion
    return (stepNumber / totalSteps).clamp(0.0, 1.0);
  }

  // Check if user can go back from current step
  static bool canGoBack(String currentStep) {
    return currentStep != 'uic' && currentStep != 'complete';
  }

  // Get remaining steps for current flow
  static List<String> getRemainingSteps(
    String currentStep,
    RegistrationData data,
  ) {
    final currentStepNumber = flowSteps[currentStep] ?? 0;
    final allSteps = flowSteps.keys.toList();

    // Filter based on user type
    if (data.userType == 'InfoSeeker') {
      // Info seekers skip PLHIV-specific steps
      return allSteps
          .where((step) => !_isPLHIVSpecificStep(step))
          .where((step) => (flowSteps[step] ?? 0) > currentStepNumber)
          .toList();
    } else {
      // PLHIV users go through all steps
      return allSteps
          .where((step) => (flowSteps[step] ?? 0) > currentStepNumber)
          .toList();
    }
  }

  // Check if step is PLHIV-specific
  static bool _isPLHIVSpecificStep(String step) {
    return [
      'yearDiag',
      'treatmentHub',
      'plhivOnboarding',
      'plhivForm',
    ].contains(step);
  }

  // Emergency recovery - reset to safe state
  static Future<void> emergencyReset() async {
    try {
      await clearProgress();
      print('✅ Emergency reset completed');
    } catch (e) {
      print('❌ Emergency reset failed: $e');
    }
  }

  // Backup registration data to multiple sources
  static Future<void> createBackup(RegistrationData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create backup with timestamp
      final backupKey = 'registration_backup_$timestamp';
      await prefs.setString(backupKey, json.encode(data.toJson()));

      // Keep only last 3 backups
      final keys =
          prefs
              .getKeys()
              .where((key) => key.startsWith('registration_backup_'))
              .toList();
      keys.sort();

      if (keys.length > 3) {
        for (int i = 0; i < keys.length - 3; i++) {
          await prefs.remove(keys[i]);
        }
      }

      print('✅ Backup created: $backupKey');
    } catch (e) {
      print('❌ Failed to create backup: $e');
    }
  }

  // Restore from backup
  static Future<RegistrationData?> restoreFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs
              .getKeys()
              .where((key) => key.startsWith('registration_backup_'))
              .toList();

      if (keys.isEmpty) return null;

      // Get most recent backup
      keys.sort();
      final latestBackup = prefs.getString(keys.last);

      if (latestBackup != null) {
        final backupData = json.decode(latestBackup);
        return RegistrationData.fromJson(backupData);
      }
    } catch (e) {
      print('❌ Failed to restore from backup: $e');
    }
    return null;
  }
}
