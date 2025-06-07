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
  CardModel("Cardiologist", 0xFFec407a, AntDesign.heart),
  CardModel("Dentist", 0xFF5c6bc0, MaterialCommunityIcons.tooth),
  CardModel("Eye Specialist", 0xFFfbc02d, TablerIcons.eye),
  CardModel("Orthopaedic", 0xFF1565C0, Icons.wheelchair_pickup_sharp),
  CardModel("Paediatrician", 0xFF2E7D32, FontAwesome5Solid.baby),
];
