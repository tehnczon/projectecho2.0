import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class CardModel {
  String doctor;
  int cardBackground;
  IconData cardIcon;

  CardModel(this.doctor, this.cardBackground, this.cardIcon);
}

List<CardModel> cards = [
  CardModel("find near center", 0xFFec407a, AntDesign.enviroment),
  CardModel("volunteers", 0xFF5c6bc0, MaterialCommunityIcons.hand_heart),
  CardModel("profiling", 0xFF00bcd4, TablerIcons.user_search),
  // CardModel("Orthopaedic", 0xFF1565C0, Icons.wheelchair_pickup_sharp),
  // CardModel("Paediatrician", 0xFF2E7D32, FontAwesome5Solid.baby),
];
