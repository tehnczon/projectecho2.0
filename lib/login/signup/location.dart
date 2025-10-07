import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/registration_flow_manager.dart';

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
      '1-A',
      '2-A',
      '3-A',
      '4-A',
      '5-A',
      '6-A',
      '7-A',
      '8-A',
      '9-A',
      '10-A',
      '11-B',
      '12-B',
      '13-B',
      '14-B',
      '15-B',
      '16-B',
      '17-B',
      '18-B',
      '19-B',
      '20-B',
      '21-C',
      '22-C',
      '23-C',
      '24-C',
      '25-C',
      '26-C',
      '27-C',
      '28-C',
      '29-C',
      '30-C',
      '31-D',
      '32-D',
      '33-D',
      '34-D',
      '35-D',
      '36-D',
      '37-D',
      '38-D',
      '39-D',
      '40-D',
      'A. Angliongto Sr.',
      'Acacia',
      'Agdao Proper',
      'Alambre',
      'Alegre',
      'Angalan',
      'Atan-Awe',
      'Bago Aplaya',
      'Bago Gallera',
      'Balengaeng',
      'Baliok',
      'Bantol',
      'Baracatan',
      'Bato',
      'Bayabas',
      'Bayabas (Toril)',
      'Bayabas (Baguio)',
      'Biao Escuela',
      'Biao Guianga',
      'Biao Joaquin',
      'Biao (Calinan)',
      'Biao (Tugbok)',
      'Binugao',
      'Bucana',
      'Buenavista',
      'Bugac',
      'Buhangin',
      'Buhangin Proper',
      'Buhangin (Poblacion)',
      'Buhangin (District II)',
      'Buhangin (District III)',
      'Bunawan',
      'Cadalian',
      'Calinan Poblacion',
      'Callawa',
      'Carmen',
      'Catalunan Grande',
      'Catalunan Pequeño',
      'Catigan',
      'Cawayan',
      'Cementerio',
      'Colosas',
      'Communal',
      'Crossing Bayabas',
      'Dacudao',
      'Dalagdag',
      'Dalag',
      'Daliao',
      'Datu Abing',
      'Davao Airport',
      'Dizon',
      'Dominga',
      'Dumoy',
      'Eden',
      'Fatima (Benowang)',
      'Gov. Paciano Bangoy',
      'Gov. Generoso',
      'Gumalang',
      'Ilang',
      'Indangan',
      'Inayangan',
      'Kabasalan',
      'Kalinan',
      'Kalunasan',
      'Kamagong',
      'Kapitan Tomas Monteverde Sr.',
      'Kasilak',
      'Katalunan Grande',
      'Katalunan Pequeño',
      'Kawayan',
      'Kilate',
      'Lacson',
      'Langub',
      'Lasang',
      'Lizada',
      'Lubogan',
      'Lumabat',
      'Lumana',
      'Maa',
      'Malabog',
      'Malagos',
      'Malamba',
      'Manambulan',
      'Mandug',
      'Marapangi',
      'Marilog',
      'Matina Aplaya',
      'Matina Crossing',
      'Matina Pangi',
      'Megkawayan',
      'Mintal',
      'Mudiang',
      'Mulig',
      'New Carmen',
      'New Valencia',
      'Pampanga',
      'Panacan',
      'Pangyan',
      'Panigan',
      'Poblacion (District A)',
      'Poblacion (District B)',
      'Riverside',
      'Saloy',
      'San Antonio',
      'San Isidro',
      'San Miguel',
      'San Rafael',
      'San Roque',
      'Sasa',
      'Sibulan',
      'Sirawan',
      'Sirib',
      'Sison',
      'Suawan',
      'Subasta',
      'Sumimao',
      'Tacunan',
      'Tagakpan',
      'Tagluno',
      'Tagurano',
      'Tamayong',
      'Tawan-Tawan',
      'Tibungco',
      'Tigatto',
      'Tugbok Proper',
      'Tungkalan',
      'Turil',
      'Ula',
      'Ulas',
      'Upian',
      'Wangan',
      'Wines',
    ],
    'Island Garden City of Samal': [
      'Adecor',
      'Anonang',
      'Aumbay',
      'Aundanao',
      'Balet',
      'Bandera',
      'Caliclic (Dangca-an)',
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
      'Miranda (Pob.)',
      'Moncado (Pob.)',
      'Pangubatan (Talicod I)',
      'Peñaplata (Pob.)',
      'Poblacion (Kaputian)',
      'San Agustin',
      'San Antonio',
      'San Isidro (Babak)',
      'San Isidro (Kaputian)',
      'San Jose (San Lapuz)',
      'San Miguel (Magamono)',
      'San Remigio',
      'Santa Cruz (Talicod II)',
      'Santo Niño',
      'Sion (Zion)',
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
    _detectLocation();
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
            Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.8),
                        AppColors.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: isDetectingLocation ? null : _detectLocation,
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
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

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
