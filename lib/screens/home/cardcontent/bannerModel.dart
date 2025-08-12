import 'package:flutter/material.dart';
import 'package:projecho/screens/home/doctorProfile.dart'; // Replace with your actual destination
import 'package:projecho/screens/home/article_screen.dart'; // Replace with your actual destination

class BannerModel {
  String text;
  List<Color> cardBackground;
  String image;
  Widget destination;

  BannerModel(this.text, this.cardBackground, this.image, this.destination);
}

List<BannerModel> bannerCards = [
  BannerModel(
    "wellness",
    [Color.fromARGB(255, 255, 215, 129), Color.fromARGB(255, 245, 198, 161)],
    "assets/wellness_bg.png",
    DoctorProfile(doctor: "Dr. John Doe"), // ✅ Sample doctor name
  ),
  BannerModel(
    "articles",
    [Color.fromARGB(255, 241, 172, 207), Color.fromARGB(255, 252, 207, 232)],
    "assets/article.png",
    ArticleScreen(), // ✅ No issue here
  ),
];
