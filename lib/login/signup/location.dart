import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/registration_flow_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const LocationScreen({super.key, required this.registrationData});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {
  String? selectedCity;
  String? selectedBarangay;
  bool isLoading = false;
  bool isDetectingLocation = false;
  late AnimationController _mapAnimationController;
  late AnimationController _pulseController;

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
      'Catalunan Pequeño',
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
      'Santo Niño',
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
      'Peñaplata',
      'Poblacion',
      'San Agustin',
      'San Antonio',
      'San Isidro (Babak)',
      'San Isidro (Kaputian)',
      'San Jose',
      'San Miguel',
      'San Remigio',
      'Santa Cruz',
      'Santo Niño',
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

  @override
  void initState() {
    super.initState();
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Auto-detect location on init
    // _detectLocation();
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => isDetectingLocation = true);
    HapticFeedback.lightImpact();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        setState(() => isDetectingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isDetectingLocation = false);
          _showErrorSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => isDetectingLocation = false);
        _showErrorSnackBar('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        print("Detected locality: ${place.locality}");
        print("Detected subLocality: ${place.subLocality}");

        setState(() {
          final normalizedCity = normalizeCity(place.locality);
          if (normalizedCity != null && cities.contains(normalizedCity)) {
            selectedCity = normalizedCity;
          } else {
            selectedCity = null; // don’t assign invalid city
          }

          final normalizedBrgy = normalizeBarangay(place.subLocality);
          if (selectedCity != null &&
              normalizedBrgy != null &&
              barangays[selectedCity]!.contains(normalizedBrgy)) {
            selectedBarangay = normalizedBrgy;
          } else {
            selectedBarangay = null;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Could not detect location');
    } finally {
      setState(() => isDetectingLocation = false);
    }
  }

  String? normalizeCity(String? city) {
    if (city == null) return null;
    if (city.contains("Samal")) return "Island Garden City of Samal";
    if (city.contains("Davao")) return "Davao City";
    return null; // return null if no match so dropdown won't break
  }

  String? normalizeBarangay(String? brgy) {
    if (brgy == null) return null;
    if (brgy.contains("Buhangin")) return "Buhangin";
    return brgy;
  }

  void _proceed() {
    if (selectedCity != null && selectedBarangay != null) {
      HapticFeedback.mediumImpact();
      widget.registrationData.city = selectedCity!;
      widget.registrationData.barangay = selectedBarangay!;

      RegistrationFlowManager.navigateToNextStep(
        context: context,
        currentStep: 'location',
        registrationData: widget.registrationData,
      );
    } else {
      _showErrorSnackBar('Please select both city and barangay');
    }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            // Map Animation
            Center(
              child: AnimatedBuilder(
                animation: _mapAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * _mapAnimationController.value),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.map, color: AppColors.primary, size: 50),
                          if (isDetectingLocation)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1 + (_pulseController.value * 0.3),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            // Title
            Text(
              'Where are you located?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 12),

            // Info Card
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This helps us connect you to nearby services and support. Your location remains confidential.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 700.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Auto-detect button
            // Accuracy Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Detected location may not be fully accurate. '
                          'City and barangay data are based on the Philippine Statistics Authority (PSA).',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 🧭 Auto-detected location display
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.8),
                          AppColors.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed:
                          isDetectingLocation
                              ? null
                              : () async {
                                final shouldContinue = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder:
                                      (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        insetPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 40,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius: 15,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                color: AppColors.primary,
                                                size: 42,
                                              ),
                                              const SizedBox(height: 14),
                                              Text(
                                                'Share Your Location?',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Are you sure you want to share your current location? '
                                                'This helps us detect your city and barangay.',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  height: 1.5,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 22),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                          color: AppColors
                                                              .textSecondary
                                                              .withOpacity(0.5),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Cancel',
                                                        style: GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors
                                                                  .textPrimary,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors.primary,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Continue',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                );

                                if (shouldContinue == true) {
                                  _detectLocation();
                                }
                              },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon:
                          isDetectingLocation
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(Icons.my_location, color: Colors.white),
                      label: Text(
                        isDetectingLocation
                            ? 'Detecting...'
                            : 'Auto-detect Location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 700.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),

            // Manual selection
            Text(
              'Or select manually:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // City Dropdown
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
                  child: DropdownButtonFormField<String>(
                    value: selectedCity,
                    decoration: InputDecoration(
                      labelText: 'Select City',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(
                        Icons.location_city,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    items:
                        cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                        selectedBarangay = null;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 16),

            // Barangay Dropdown
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
                  child: DropdownButtonFormField<String>(
                    value: selectedBarangay,
                    decoration: InputDecoration(
                      labelText: 'Select Barangay',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    items:
                        selectedCity != null &&
                                barangays.containsKey(selectedCity)
                            ? barangays[selectedCity]!
                                .map(
                                  (brgy) => DropdownMenuItem(
                                    value: brgy,
                                    child: Text(brgy),
                                  ),
                                )
                                .toList()
                            : [],
                    onChanged:
                        selectedCity == null
                            ? null
                            : (value) {
                              setState(() => selectedBarangay = value);
                              HapticFeedback.lightImpact();
                            },
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideX(begin: -0.1, end: 0),

            const SizedBox(height: 40),

            // Continue Button
            Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient:
                        (selectedCity != null && selectedBarangay != null)
                            ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            )
                            : null,
                    color:
                        (selectedCity == null || selectedBarangay == null)
                            ? AppColors.divider
                            : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        (selectedCity != null && selectedBarangay != null)
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ]
                            : [],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        (selectedCity != null && selectedBarangay != null)
                            ? _proceed
                            : null,
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
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                (selectedCity != null &&
                                        selectedBarangay != null)
                                    ? Colors.white
                                    : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color:
                              (selectedCity != null && selectedBarangay != null)
                                  ? Colors.white
                                  : AppColors.textSecondary,
                        ),
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
