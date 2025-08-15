import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/login/signup/location.dart';
import 'package:projecho/main/registration_data.dart';

class UICScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const UICScreen({super.key, required this.registrationData});

  @override
  State<UICScreen> createState() => _UICScreenState();
}

class _UICScreenState extends State<UICScreen>
    with SingleTickerProviderStateMixin {
  final _motherController = TextEditingController();
  final _fatherController = TextEditingController();
  final _birthOrderController = TextEditingController();
  DateTime? _selectedDate;
  late AnimationController _animationController;
  String _generatedUIC = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _motherController.dispose();
    _fatherController.dispose();
    _birthOrderController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    HapticFeedback.lightImpact();
    DateTime initial = DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(
        DateTime.now().year - 13,
        DateTime.now().month,
        DateTime.now().day,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updateUIC();
      });
    }
  }

  void _updateUIC() {
    String mother = _motherController.text.trim();
    String father = _fatherController.text.trim();
    String birthOrderStr = _birthOrderController.text.trim();

    if (mother.isNotEmpty && father.isNotEmpty && _selectedDate != null) {
      String motherCode =
          mother.length >= 2
              ? mother.substring(0, 2).toUpperCase()
              : mother.padRight(2, 'X').toUpperCase();

      String fatherCode =
          father.length >= 2
              ? father.substring(0, 2).toUpperCase()
              : father.padRight(2, 'X').toUpperCase();

      int? birthOrder = int.tryParse(birthOrderStr);
      String birthOrderCode =
          (birthOrder == null || birthOrder <= 0)
              ? "99"
              : birthOrder.toString().padLeft(2, '0');

      String birthDateCode =
          "${_selectedDate!.month.toString().padLeft(2, '0')}"
          "${_selectedDate!.day.toString().padLeft(2, '0')}"
          "${_selectedDate!.year}";

      setState(() {
        _generatedUIC = "$motherCode$fatherCode$birthOrderCode$birthDateCode";
      });
    }
  }

  void _handleNext() {
    if (_motherController.text.isEmpty ||
        _fatherController.text.isEmpty ||
        _birthOrderController.text.isEmpty ||
        _selectedDate == null) {
      _showErrorSnackBar('Please complete all fields');
      return;
    }

    // Age verification
    final now = DateTime.now();
    final age = now.year - _selectedDate!.year;
    if (age < 13) {
      _showErrorSnackBar('You must be at least 13 years old to continue');
      return;
    }

    HapticFeedback.mediumImpact();
    widget.registrationData.birthDate = _selectedDate;
    widget.registrationData.generatedUIC = _generatedUIC;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => LocationScreen(registrationData: widget.registrationData),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => _updateUIC(),
        style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintStyle: TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.primary),
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
      ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                child: Icon(Icons.fingerprint, color: Colors.white, size: 40),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            ),

            const SizedBox(height: 24),

            Text(
              'Create Your Unique ID',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 8),

            Text(
              'This helps us keep your records secure and confidential',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

            const SizedBox(height: 32),

            // UIC Preview
            if (_generatedUIC.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your UIC',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _generatedUIC,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
              ),

            // Form Fields
            _buildModernTextField(
                  label: "Mother's First Name",
                  controller: _motherController,
                  icon: Icons.person_outline,
                  hint: "Enter mother's first name",
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.1, end: 0),

            _buildModernTextField(
                  label: "Father's First Name",
                  controller: _fatherController,
                  icon: Icons.person_outline,
                  hint: "Enter father's first name",
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideX(begin: -0.1, end: 0),

            _buildModernTextField(
                  label: "Birth Order",
                  controller: _birthOrderController,
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                  hint: "e.g., 1, 2, 3",
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideX(begin: -0.1, end: 0),

            // Date Picker
            InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? "Select Birthdate"
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedDate == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This information is used only to generate your UIC and will not be stored',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

            const SizedBox(height: 32),

            // Continue Button
            Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 700.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

// // Placeholder for ModernLocationScreen - Add this to complete the flow
// class ModernLocationScreen extends StatelessWidget {
//   final dynamic registrationData;

//   const ModernLocationScreen({super.key, required this.registrationData});

//   @override
//   Widget build(BuildContext context) {
//     // Implement your location screen here
//     return Container();
//   }
// }
