import 'package:flutter/material.dart';
import 'package:projecho/login/signup/location.dart';
import 'package:projecho/map/models/registration_data.dart';

class UICScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const UICScreen({super.key, required this.registrationData});

  @override
  State<UICScreen> createState() => _UICScreenState();
}

class _UICScreenState extends State<UICScreen> with TickerProviderStateMixin {
  final _motherController = TextEditingController();
  final _fatherController = TextEditingController();
  final _birthOrderController = TextEditingController();
  DateTime? _selectedDate;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _motherController.dispose();
    _fatherController.dispose();
    _birthOrderController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime initial = DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(
        DateTime.now().year - 13,
        DateTime.now().month,
        DateTime.now().day,
      ), // age limit
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleNext() {
    String mother = _motherController.text.trim();
    String father = _fatherController.text.trim();
    String birthOrderStr = _birthOrderController.text.trim();

    if (mother.isEmpty ||
        father.isEmpty ||
        birthOrderStr.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    // Age verification
    final now = DateTime.now();
    final age =
        now.year -
        _selectedDate!.year -
        ((now.month < _selectedDate!.month ||
                (now.month == _selectedDate!.month &&
                    now.day < _selectedDate!.day))
            ? 1
            : 0);
    if (age < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be at least 13 years old to continue."),
        ),
      );
      return;
    }

    // Birth Order fallback
    int? birthOrder = int.tryParse(birthOrderStr);
    String birthOrderCode =
        (birthOrder == null || birthOrder <= 0)
            ? "99"
            : birthOrder.toString().padLeft(2, '0');

    // Initial fallback helper
    String extractInitials(String name) {
      List<String> parts = name.split(" ");
      if (parts.length >= 2) {
        return "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else if (parts.length == 1 && parts[0].length >= 2) {
        return parts[0].substring(0, 2).toUpperCase();
      } else {
        return "XX";
      }
    }

    // Generate parent codes
    String motherCode =
        mother.length >= 2
            ? mother.substring(0, 2).toUpperCase()
            : extractInitials(mother);
    String fatherCode =
        father.length >= 2
            ? father.substring(0, 2).toUpperCase()
            : extractInitials(father);

    // Birthdate code
    String birthDateCode =
        _selectedDate != null
            ? "${_selectedDate!.month.toString().padLeft(2, '0')}${_selectedDate!.day.toString().padLeft(2, '0')}${_selectedDate!.year}"
            : "99999999";

    // Final UIC
    String uicCode = "$motherCode$fatherCode$birthOrderCode$birthDateCode";

    // Save to registration data
    // widget.registrationData.motherFirstName = mother;
    // widget.registrationData.fatherFirstName = father;
    // widget.registrationData.birthOrder = birthOrder ?? 99;
    widget.registrationData.birthDate = _selectedDate;
    widget.registrationData.generatedUIC = uicCode;

    // Navigate to user type screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => LocationScreen(registrationData: widget.registrationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Let's generate your Unique Identifier Code (UIC)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This will help us keep your records secure and make your future visits smoother.\n"
                    "Your UIC is confidential and used only for your privacy and protection.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField("Mother's First Name", _motherController),

            const SizedBox(height: 12),
            _buildTextField("Father's First Name", _fatherController),
            const SizedBox(height: 4),

            const Text(
              "This information is used only to generate your UIC and will not be stored.",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            _buildTextField(
              "Birth Order (e.g. 1, 2, 3)",
              _birthOrderController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 4),
            const Text(
              "If unknown, enter 99. This field is used only for UIC generation.",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Birthdate",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Tap to select date"
                      : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Note:\n"
              "• If parent's name is unknown, use your initials (first & last name, e.g. Mark Anthony = M F).\n"
              "• For unknown birth order or birthday, replace each with '9' (e.g. 99).",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
