import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/models/registration_data.dart';
import 'package:projecho/plhiv_form/confirmatorycode.dart';

class YearDiagPage extends StatefulWidget {
  final RegistrationData registrationData;

  const YearDiagPage({super.key, required this.registrationData});

  @override
  State<YearDiagPage> createState() => _YearDiagPageState();
}

class _YearDiagPageState extends State<YearDiagPage> {
  int? selectedYear;

  List<int> _generateYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(31, (index) => currentYear - index); // 30 years range
  }

  void _onSubmit() {
    if (selectedYear != null) {
      widget.registrationData.yearDiagnosed = selectedYear;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ConfirmatoryCodeScreen(
                registrationData: widget.registrationData,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your year of diagnosis")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearList = _generateYearList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "When were you diagnosed with HIV?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ).animate().fade(duration: 500.ms).slideY(begin: 0.3),

            const SizedBox(height: 12),

            const Text(
              "This information helps us verify your profile and offer more appropriate support. It will remain confidential and is used only for validation purposes.",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ).animate().fade(duration: 800.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: yearList.length,
                itemBuilder: (context, index) {
                  final year = yearList[index];
                  final isSelected = selectedYear == year;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedYear = year;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey[200],
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "$year",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .animate(delay: (100 * index).ms)
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.1),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ).animate().fade().slideY(begin: 0.1),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                "Your diagnosis year helps us understand your journey. You’re not alone.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ).animate().fade(duration: 1000.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}
