import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:projecho/login/signup/plhivForm/app_colors.dart';
import 'package:projecho/screens/med_tracker/medication_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogRefillScreen extends StatefulWidget {
  const LogRefillScreen({Key? key}) : super(key: key);

  @override
  State<LogRefillScreen> createState() => _LogRefillScreenState();
}

class _LogRefillScreenState extends State<LogRefillScreen> {
  int bottlesOnHand = 0;
  final TextEditingController _hubController = TextEditingController();
  List<String> _treatmentHubs = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTreatmentHubs();
    _loadUserHub();
  }

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

  Future<void> _loadTreatmentHubs() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('centers').get();
      final centers =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _treatmentHubs = ['Prefer not to share', ...centers];
      });
    } catch (e) {
      print('Error fetching treatment hubs: $e');
      setState(() {
        _treatmentHubs = ['Prefer not to share'];
      });
    }
  }

  Future<void> _loadUserHub() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final roleDataDoc =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .collection('roleData')
              .doc('plhiv')
              .get();

      if (roleDataDoc.exists &&
          roleDataDoc.data()!.containsKey('treatmentHub')) {
        final hubName = roleDataDoc['treatmentHub'];
        setState(() {
          _hubController.text = hubName ?? 'Prefer not to share';
        });
      } else {
        setState(() {
          _hubController.text = 'Prefer not to share';
        });
      }
    } catch (e) {
      print('Error loading user hub: $e');
      setState(() {
        _hubController.text = 'Prefer not to share';
      });
    }
  }

  void _showBottlesPicker(BuildContext context) {
    int tempValue = bottlesOnHand;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Set Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (tempValue > 0) {
                              setDialogState(() {
                                tempValue--;
                              });
                            }
                          },
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.remove),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$tempValue',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              tempValue++;
                            });
                          },
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            bottlesOnHand = tempValue;
                          });
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateCabinet() async {
    // Validate input
    if (bottlesOnHand == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please set the number of bottles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final medProvider = Provider.of<MedicationProvider>(context, listen: false);

    // Call logRefill - 1 bottle = 30 pills
    final success = await medProvider.logRefill(
      bottles: bottlesOnHand,
      hub: _hubController.text.isNotEmpty ? _hubController.text : null,
    );

    setState(() {
      isSaving = false;
    });

    if (success && mounted) {
      final totalPills = bottlesOnHand * 30;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Added $bottlesOnHand bottle${bottlesOnHand > 1 ? 's' : ''} ($totalPills pills) to your cabinet!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Failed to log refill. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Log New Refill',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Got a new bottle? Awesome. Let's add it here to update your supply and help you stay on track.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "We'll automatically add this to your drug cabinet supply.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Image.asset(
                        'assets/bottle_check.png',
                        height: 180,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              size: 80,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bottles on Hand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showBottlesPicker(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '$bottlesOnHand Bottle(s) = ${bottlesOnHand * 30} pills',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'My Treatment Hub',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
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
                        "Choose Treatment Hub",
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      items:
                          _treatmentHubs.map((hub) {
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
                    const SizedBox(height: 16),
                    const Text(
                      'Helpful tip: Keeping this info updated helps us set you the most accurate reminders.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _updateCabinet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Update Cabinet',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hubController.dispose();
    super.dispose();
  }
}
