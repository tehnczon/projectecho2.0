import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:projecho/model/cardModel.dart';
import 'package:projecho/carouselSlider.dart';
// import 'package:projecho/screens/exploreList.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _doctorName = TextEditingController();

  @override
  void dispose() {
    _doctorName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message;
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      message = 'Good Morning';
    } else if (hour >= 12 && hour <= 17) {
      message = 'Good Afternoon';
    } else {
      message = 'Good Evening';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  message,
                  style: GoogleFonts.lato(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 55),
              IconButton(
                splashRadius: 20,
                icon: Icon(Icons.notifications_active),
                onPressed: () {},
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
  overscroll.disallowIndicator();
  return true;
},

          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                children: [
                  SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      "Hello User",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20, bottom: 25),
                    child: Text(
                      "Let's Find Your\nDoctor",
                      style: GoogleFonts.lato(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 25),
                    child: TextFormField(
                      textInputAction: TextInputAction.search,
                      controller: _doctorName,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Search doctor',
                        hintStyle: GoogleFonts.lato(
                          color: Colors.black26,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        suffixIcon: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[900]?.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            iconSize: 20,
                            splashRadius: 20,
                            color: Colors.white,
                            icon: Icon(AntDesign.search1),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      onFieldSubmitted: (String value) {
                        // No backend search
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 23, bottom: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "We care for you",
                      style: GoogleFonts.lato(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Carouselslider(),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Specialists",
                      style: GoogleFonts.lato(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    height: 150,
                    padding: EdgeInsets.only(top: 14),
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 14),
                          height: 150,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(cards[index].cardBackground),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[400]!,
                                blurRadius: 4.0,
                                spreadRadius: 0.0,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color(cards[index].cardBackground),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 16),
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 29,
                                  child: Icon(
                                    cards[index].cardIcon,
                                    size: 26,
                                    color: Color(cards[index].cardBackground),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  cards[index].doctor,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Top Rated",
                      style: GoogleFonts.lato(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      "No data available.",
                      style: GoogleFonts.lato(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
