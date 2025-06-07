import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:projecho/screens/userSettings.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String displayName = "John Doe";
  final String email = "johndoe@example.com";
  final String phoneNumber = "";
  final String bio = "No Bio";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
         onNotification: (OverscrollIndicatorNotification overscroll) {
  overscroll.disallowIndicator();
  return true;
          },
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.1, 0.5],
                            colors: [
                              Colors.indigo,
                              Colors.indigoAccent,
                            ],
                          ),
                        ),
                        height: MediaQuery.of(context).size.height / 5,
                        child: Container(
                          padding: const EdgeInsets.only(top: 10, right: 7),
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(
                              FontAwesome.gear,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  UserSettings(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height / 5,
                        padding: const EdgeInsets.only(top: 75),
                        child: Text(
                          displayName,
                          style: GoogleFonts.lato(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.teal.shade50,
                        width: 5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/person.jpg'),
                    ),
                  ),
                ],
              ),
              _infoCard(context),
              _bioCard(),
              _appointmentCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.only(left: 20),
      height: MediaQuery.of(context).size.height / 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueGrey[50],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _infoRow(Icons.mail_rounded, email, Colors.red[900]!),
          const SizedBox(height: 15),
          _infoRow(Icons.phone, phoneNumber.isEmpty ? "Not Added" : phoneNumber, Colors.blue[800]!),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 27,
            width: 27,
            color: color,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _bioCard() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
      padding: const EdgeInsets.only(left: 20, top: 20),
      height: MediaQuery.of(context).size.height / 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueGrey[50],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 27,
                  width: 27,
                  color: Colors.indigo[600],
                  child: const Icon(Entypo.pencil, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bio',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 10, left: 40),
            child: Text(
              bio,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
      padding: const EdgeInsets.only(left: 20, top: 20),
      height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueGrey[50],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 27,
                  width: 27,
                  color: Colors.green[900],
                  child: const Icon(FontAwesome.history, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Appointment History",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 30,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('View all'),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Scrollbar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No appointment history.",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
