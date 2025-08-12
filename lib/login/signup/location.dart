import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projecho/map/models/registration_data.dart';
import 'package:projecho/login/signup/genID.dart';

class LocationScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const LocationScreen({super.key, required this.registrationData});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? selectedCity;
  String? selectedBarangay;
  bool isLoading = false;

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
    detectLocation();
  }

  Future<void> detectLocation() async {
    setState(() {
      isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      setState(() {
        isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          selectedCity = place.locality ?? place.subAdministrativeArea ?? '';
          selectedBarangay = place.subLocality ?? '';
        });
      }
    } catch (e) {
      // Optionally handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void proceed() {
    if (selectedCity != null && selectedBarangay != null) {
      widget.registrationData.city = selectedCity!;
      widget.registrationData.barangay = selectedBarangay!;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => GenderSelectionScreen(
                registrationData: widget.registrationData,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select city and barangay.")),
      );
    }
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  children: [
                    const Text(
                      "Where are you located?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please enter your current location. This helps us connect you to nearby services and support. Your information remains confidential.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      decoration: InputDecoration(
                        labelText: "Select City",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedBarangay,
                      decoration: InputDecoration(
                        labelText: "Select Barangay",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      onChanged: (value) {
                        setState(() {
                          selectedBarangay = value;
                        });
                      },
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: proceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
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
}
