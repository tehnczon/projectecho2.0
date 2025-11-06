import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/login/signup/plhivForm/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/static/privacyPolicy.dart';
import 'package:projecho/static/terms.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _isScrolled = false;
  bool _isExpanded = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditingUIC = false;
  String? selectedCity;
  String? selectedBarangay;

  final List<String> cities = ['Davao City', 'Island Garden City of Samal'];
  final Map<String, List<String>> barangays = {
    'Davao City': [
      'Acacia',
      'Agdao',
      'Alambre',
      'Atan-Awe',
      'Bago Gallera',
      'Bago Oshiro',
      'Baguio',
      'Balengaeng',
      'Baliok',
      'Bangkas Heights',
      'Baracatan',
      'Bato',
      'Bayabas',
      'Biao Escuela',
      'Biao Guianga',
      'Biao Joaquin',
      'Binugao',
      'Bucana',
      'Buhangin',
      'Bunawan',
      'Cabantian',
      'Cadalian',
      'Calinan',
      'Callawa',
      'Camansi',
      'Carmen',
      'Catalunan Grande',
      'Catalunan PequeÃ±o',
      'Catigan',
      'Cawayan',
      'Colosas',
      'Communal',
      'Crossing Bayabas',
      'Dacudao',
      'Dalag',
      'Dalagdag',
      'Daliao',
      'Daliaon Plantation',
      'Dominga',
      'Dumoy',
      'Eden',
      'Fatima',
      'Gatungan',
      'Gumalang',
      'Ilang',
      'Indangan',
      'Kilate',
      'Lacson',
      'Lamanan',
      'Lampianao',
      'Langub',
      'Alejandra Navarro',
      'Lizada',
      'Los Amigos',
      'Lubogan',
      'Lumiad',
      'Ma-a',
      'Mabuhay',
      'Magtuod',
      'Mahayag',
      'Malabog',
      'Malagos',
      'Malamba',
      'Manambulan',
      'Mandug',
      'Manuel Guianga',
      'Mapula',
      'Marapangi',
      'Marilog',
      'Matina Aplaya',
      'Matina Crossing',
      'Matina Pangi',
      'Matina Biao',
      'Mintal',
      'Mudiang',
      'Mulig',
      'New Carmen',
      'New Valencia',
      'Pampanga',
      'Panacan',
      'Panalum',
      'Pandaitan',
      'Pangyan',
      'Paquibato',
      'Paradise Embak',
      'Riverside',
      'Salapawan',
      'Salaysay',
      'San Isidro',
      'Sasa',
      'Sibulan',
      'Sirawan',
      'Sirib',
      'Suawan',
      'Subasta',
      'Sumimao',
      'Tacunan',
      'Tagakpan',
      'Tagluno',
      'Tagurano',
      'Talandang',
      'Talomo',
      'Talomo River',
      'Tamayong',
      'Tambobong',
      'Tamugan',
      'Tapak',
      'Tawan-tawan',
      'Tibuloy',
      'Tibungco',
      'Tigatto',
      'Toril',
      'Tugbok',
      'Tungakalan',
      'Ula',
      'Wangan',
      'Wines',
      'Barangay 1-A',
      'Barangay 2-A',
      'Barangay 3-A',
      'Barangay 4-A',
      'Barangay 5-A',
      'Barangay 6-A',
      'Barangay 7-A',
      'Barangay 8-A',
      'Barangay 9-A',
      'Barangay 10-A',
      'Barangay 11-B',
      'Barangay 12-B',
      'Barangay 13-B',
      'Barangay 14-B',
      'Barangay 15-B',
      'Barangay 16-B',
      'Barangay 17-B',
      'Barangay 18-B',
      'Barangay 19-B',
      'Barangay 20-B',
      'Barangay 21-C',
      'Barangay 22-C',
      'Barangay 23-C',
      'Barangay 24-C',
      'Barangay 25-C',
      'Barangay 26-C',
      'Barangay 27-C',
      'Barangay 28-C',
      'Barangay 29-C',
      'Barangay 30-C',
      'Barangay 31-D',
      'Barangay 32-D',
      'Barangay 33-D',
      'Barangay 34-D',
      'Barangay 35-D',
      'Barangay 36-D',
      'Barangay 37-D',
      'Barangay 38-D',
      'Barangay 39-D',
      'Barangay 40-D',
      'Angalan',
      'Baganihan',
      'Bago Aplaya',
      'Bantol',
      'Buda',
      'Centro',
      'Datu Salumay',
      'Gov. Paciano Bangoy',
      'Gov. Vicente Duterte',
      'Gumitan',
      'Inayangan',
      'Kap. Tomas Monteverde, Sr.',
      'Lapu-lapu',
      'Leon Garcia, Sr.',
      'Magsaysay',
      'Megkawayan',
      'Rafael Castillo',
      'Saloy',
      'San Antonio',
      'Santo NiÃ±o',
      'Ubalde',
      'Waan',
      'Wilfredo Aquino',
      'Alfonso Angliongto Sr.',
      'Vicente Hizon Sr.',
    ],
    'Island Garden City of Samal': [
      'Adecor',
      'Anonang',
      'Aumbay',
      'Aundanao',
      'Balet',
      'Bandera',
      'Caliclic',
      'Camudmud',
      'Catagman',
      'Cawag',
      'Cogon',
      'Cogon (Talicod)',
      'Dadatan',
      'Del Monte',
      'Guilon',
      'Kanaan',
      'Kinawitnon',
      'Libertad',
      'Libuak',
      'Licup',
      'Limao',
      'Linosutan',
      'Mambago-A',
      'Mambago-B',
      'Miranda',
      'Moncado',
      'Pangubatan',
      'PeÃ±aplata',
      'Poblacion',
      'San Agustin',
      'San Antonio',
      'San Isidro (Babak)',
      'San Isidro (Kaputian)',
      'San Jose',
      'San Miguel',
      'San Remigio',
      'Santa Cruz',
      'Santo NiÃ±o',
      'Sion',
      'Tagbaobo',
      'Tagbay',
      'Tagbitan-ag',
      'Tagdaliao',
      'Tagpopongan',
      'Tambo',
      'Toril',
    ],
  };

  // Form controllers
  final TextEditingController _customGenderController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _birthOrderController = TextEditingController();

  DateTime? _selectedDate;
  String _generatedUIC = '';

  // Form values
  String? _selectedGenderIdentity;
  String? _selectedYearDiagnosed;
  String? _selectedTreatmentHub;
  String? _userRole;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Transgender',
    'Non-binary',
    'Prefer not to say',
    'Other',
  ];

  List<String> _treatmentHubs = [];
  List<String> _yearOptions = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _generateYearList();
    _loadProfileData();
    _loadTreatmentHubs();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _customGenderController.dispose();
    _motherController.dispose();
    _fatherController.dispose();
    _birthOrderController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isScrolled = _scrollOffset > 100;
    });
  }

  void _generateYearList() {
    final currentYear = DateTime.now().year;
    _yearOptions = ['Prefer not to share'];
    _yearOptions.addAll(
      List.generate(100, (index) => (currentYear - index).toString()),
    );
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

  void _pickDate() async {
    HapticFeedback.lightImpact();
    DateTime initial = _selectedDate ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final profileDoc =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .get();

      if (profileDoc.exists) {
        final data = profileDoc.data()!;
        setState(() {
          _generatedUIC = data['generatedUIC'] ?? '';
          _selectedGenderIdentity = data['genderIdentity'];
          _customGenderController.text = data['customGender'] ?? '';

          final location = data['location'] as Map<String, dynamic>?;
          // Load city and barangay, ensuring they match the dropdown values
          String? loadedCity = location?['city'];
          String? loadedBarangay = location?['barangay'];

          // Only set if the value exists in our dropdown list
          selectedCity =
              (loadedCity != null && cities.contains(loadedCity))
                  ? loadedCity
                  : null;
          selectedBarangay =
              (loadedBarangay != null &&
                      selectedCity != null &&
                      barangays[selectedCity]?.contains(loadedBarangay) == true)
                  ? loadedBarangay
                  : null;

          // Debug: print what was loaded
          print('Loaded city: $loadedCity, Selected: $selectedCity');
          print(
            'Loaded barangay: $loadedBarangay, Selected: $selectedBarangay',
          );
        });

        final userDoc =
            await FirebaseFirestore.instance
                .collection('user')
                .doc(user.uid)
                .get();
        if (userDoc.exists) {
          _userRole = userDoc.data()?['role'];

          if (_userRole == 'plhiv') {
            final roleDataDoc =
                await FirebaseFirestore.instance
                    .collection('profiles')
                    .doc(user.uid)
                    .collection('roleData')
                    .doc('plhiv')
                    .get();

            if (roleDataDoc.exists) {
              final roleData = roleDataDoc.data()!;
              setState(() {
                _selectedYearDiagnosed = roleData['yearDiagnosed']?.toString();
                _selectedTreatmentHub = roleData['treatmentHub'];
              });
            }
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Confirm Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to update your profile information?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your changes will be saved permanently',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? finalCustomGender =
          (_selectedGenderIdentity == 'Other')
              ? _customGenderController.text
              : null;

      await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set(
        {
          'generatedUIC': _generatedUIC,
          'location': {
            'city': selectedCity ?? '',
            'barangay': selectedBarangay ?? '',
          },
          'genderIdentity': _selectedGenderIdentity,
          'customGender': finalCustomGender,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (_userRole == 'plhiv') {
        final yearDiagnosed =
            _selectedYearDiagnosed == 'Prefer not to share'
                ? null
                : int.tryParse(_selectedYearDiagnosed ?? '');
        final treatmentHub =
            _selectedTreatmentHub == 'Prefer not to share'
                ? null
                : _selectedTreatmentHub;

        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .collection('roleData')
            .doc('plhiv')
            .set({
              'yearDiagnosed': yearDiagnosed,
              'treatmentHub': treatmentHub,
            }, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      setState(() {
        _isExpanded = false;
      });
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Failed to update profile. Please try again.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    IconData? icon,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
              maxLines: maxLines,
              onChanged: onChanged,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
                prefixIcon:
                    icon != null ? Icon(icon, color: AppColors.primary) : null,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                prefixIcon:
                    prefixIcon != null
                        ? Icon(prefixIcon, color: AppColors.primary)
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              dropdownColor: Colors.white,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              items:
                  items.map((String item) {
                    final isPreferNotToShare =
                        item.toLowerCase() == 'prefer not to share';
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color:
                              isPreferNotToShare ? Colors.red : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (!_isScrolled)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Image.asset(
                  'assets/change_profile.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 250,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Edit your Profiling Data',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.surface,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Edit Your Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child:
                          _isExpanded
                              ? _buildExpandedContent()
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "By continuing, you agree to our ",
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Terms(),
                                ),
                              ),
                          child: Text(
                            "Terms ",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          "and have read our ",
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Privacypolicy(),
                                ),
                              ),
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
      child:
          _isLoading
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Unique ID',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _generatedUIC.isEmpty
                                      ? 'No UIC yet'
                                      : _generatedUIC,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              if (_generatedUIC.isNotEmpty)
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: _generatedUIC),
                                    );
                                    HapticFeedback.lightImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'UIC copied to clipboard!',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.content_copy,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isEditingUIC = !_isEditingUIC;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color:
                                _isEditingUIC
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.edit,
                            color:
                                _isEditingUIC
                                    ? Colors.white
                                    : AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child:
                        _isEditingUIC
                            ? _buildUICEditor()
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 24),
                  Text(
                    'Personal Information',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Gender Identity',
                    value: _selectedGenderIdentity,
                    items: _genderOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedGenderIdentity = value;
                      });
                    },
                  ),
                  if (_selectedGenderIdentity == 'Other')
                    _buildTextField(
                      label: 'Please Specify Gender',
                      controller: _customGenderController,
                    ),
                  _buildDropdown(
                    label: 'City',
                    value: selectedCity,
                    items: cities,
                    prefixIcon: Icons.location_city,
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                        selectedBarangay = null;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  _buildDropdown(
                    label: 'Barangay',
                    value: selectedBarangay,
                    items:
                        selectedCity != null &&
                                barangays.containsKey(selectedCity)
                            ? barangays[selectedCity]!
                            : [],
                    prefixIcon: Icons.location_on,
                    onChanged: (value) {
                      setState(() {
                        selectedBarangay = value;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  if (_userRole == 'plhiv') ...[
                    Divider(color: AppColors.divider, height: 32),
                    Text(
                      'HIV Information',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Year Diagnosed',
                      value: _selectedYearDiagnosed,
                      items: _yearOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedYearDiagnosed = value;
                        });
                      },
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                    _buildDropdown(
                      label: 'Treatment Hub',
                      value: _selectedTreatmentHub,
                      items: _treatmentHubs,
                      onChanged: (value) {
                        setState(() {
                          _selectedTreatmentHub = value;
                        });
                      },
                      prefixIcon: Icons.local_hospital,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isSaving
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Save Changes',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildUICEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fill in all fields to generate a new UIC',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Mother's First Name",
          controller: _motherController,
          icon: Icons.person_outline,
          hint: "Enter mother's first name",
          onChanged: (_) => _updateUIC(),
        ),
        _buildTextField(
          label: "Father's First Name",
          controller: _fatherController,
          icon: Icons.person_outline,
          hint: "Enter father's first name",
          onChanged: (_) => _updateUIC(),
        ),
        _buildTextField(
          label: "Birth Order",
          controller: _birthOrderController,
          icon: Icons.format_list_numbered,
          keyboardType: TextInputType.number,
          hint: "e.g., 1, 2, 3",
          onChanged: (_) => _updateUIC(),
        ),
        Text(
          'Birthdate',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color:
                          _selectedDate == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_generatedUIC.isNotEmpty) {
                HapticFeedback.mediumImpact();
                setState(() {
                  _isEditingUIC = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('UIC updated! Remember to save changes below.'),
                      ],
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields to generate UIC'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save UIC',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
