import 'package:flutter/material.dart';

class BannerModel {
  String text;
  List<Color> cardBackground;
  String image;

  BannerModel(this.text, this.cardBackground, this.image);
}

List<BannerModel> bannerCards = [
  BannerModel(
      "wellness",
      [
        Color(0xffa1d4ed),
        Color(0xffc0eaff),
      ],
      "assets/414-bg.png"),
  BannerModel(
      "articles",
      [
        Color(0xffb6d4fa),
        Color(0xffcfe3fc),
      ],
      "assets/19834-bg.png"),
];
