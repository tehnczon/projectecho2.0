import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projecho/model/registration_data.dart';
import 'package:projecho/login/signup/genID.dart';

// import 'user_type_screen.dart';

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

  final List<String> cities = ['Davao City', 'Quezon City', 'Cebu City'];
  final Map<String, List<String>> barangays = {
    'Davao City': ['Buhangin', 'Toril', 'Matina'],
    'Quezon City': ['Commonwealth', 'Cubao', 'Batasan'],
    'Cebu City': ['Lahug', 'Mabolo', 'Guadalupe'],
  };

  @override
  void initState() {
    super.initState();
    detectLocation(); // Automatically detect location on screen load
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
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
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

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

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

      // Navigate to next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GenderSelectionScreen(registrationData: widget.registrationData),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                children: [
                  const Text(
                    "Where are you located?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your current location. This helps us connect you to nearby services and support. Your information remains confidential.",
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    decoration: InputDecoration(
                      labelText: "Select City",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: cities
                        .map((city) => DropdownMenuItem(value: city, child: Text(city)))
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: selectedCity != null
                        ? barangays[selectedCity]!
                            .map((brgy) => DropdownMenuItem(value: brgy, child: Text(brgy)))
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

