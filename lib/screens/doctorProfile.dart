import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfile extends StatefulWidget {
  final String doctor;

  const DoctorProfile({super.key, required this.doctor});
  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  // Dummy doctor data for UI demonstration
  final Map<String, dynamic> document = {
    'image': 'https://via.placeholder.com/150',
    'name': 'Dr. John Doe',
    'type': 'Cardiologist',
    'rating': 4,
    'specification': 'Expert in heart diseases and treatments.',
    'address': '123 Main Street, City',
    'phone': '+1234567890',
    'openHour': '09:00 AM',
    'closeHour': '05:00 PM',
  };

  _launchCaller(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
  overscroll.disallowIndicator();
  return true;
          },
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 5),
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_left_sharp,
                    color: Colors.indigo,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(document['image']),
                radius: 80,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                document['name'],
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                document['type'],
                style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.black54),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < document['rating']; i++)
                    Icon(
                      Icons.star_rounded,
                      color: Colors.indigoAccent,
                      size: 30,
                    ),
                  if (5 - document['rating'] > 0)
                    for (var i = 0; i < 5 - document['rating']; i++)
                      Icon(
                        Icons.star_rounded,
                        color: Colors.black12,
                        size: 30,
                      ),
                ],
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                padding: EdgeInsets.only(left: 22, right: 22),
                alignment: Alignment.center,
                child: Text(
                  document['specification'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Icon(Icons.place_outlined),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: Text(
                        document['address'],
                        style: GoogleFonts.lato(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 12,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Icon(MaterialCommunityIcons.phone_in_talk),
                    SizedBox(
                      width: 11,
                    ),
                    TextButton(
                      onPressed: () =>
                          _launchCaller("tel:" + document['phone']),
                      child: Text(
                        document['phone'].toString(),
                        style: GoogleFonts.lato(
                            fontSize: 16, color: Colors.blue),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 0,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Icon(Icons.access_time_rounded),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Working Hours',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.only(left: 60),
                child: Row(
                  children: [
                    Text(
                      'Today: ',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      document['openHour'] +
                          " - " +
                          document['closeHour'],
                      style: GoogleFonts.lato(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, elevation: 2, backgroundColor: Colors.indigo.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  onPressed: () {
                    //Navigator.push();
                  },
                  child: Text(
                    'Book an Appointment',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
