import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/screens/doctorProfile.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class ExploreList extends StatefulWidget {
  final String type;
  const ExploreList({required Key key, required this.type}) : super(key: key);

  @override
  _ExploreListState createState() => _ExploreListState();
}

class _ExploreListState extends State<ExploreList> {
  // Dummy data for demonstration
  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Alice Smith',
      'type': 'Cardiologist',
      'rating': 4.8,
    },
    {
      'name': 'Dr. Bob Johnson',
      'type': 'Cardiologist',
      'rating': 4.6,
    },
    {
      'name': 'Dr. Carol Lee',
      'type': 'Cardiologist',
      'rating': 4.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter doctors by type
    final filteredDoctors =
        doctors.where((doc) => doc['type'] == widget.type).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '${widget.type}s',
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredDoctors.length,
          itemBuilder: (context, index) {
            final doctor = filteredDoctors[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                color: Colors.blue[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 9,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorProfile(
                            doctor: doctor['name'],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 25,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              doctor['name'],
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              doctor['type'],
                              style: GoogleFonts.lato(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Typicons.star_full_outline,
                                  size: 20,
                                  color: Colors.indigo[400],
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  doctor['rating'].toString(),
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
