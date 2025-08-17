import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class CardModel {
  final String title;
  final String subtitle;
  final String route;
  final List<Color> gradient;
  final IconData icon;

  CardModel({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.gradient,
    required this.icon,
  });
}

final List<CardModel> Cards = [
  CardModel(
    title: 'Treatment Centers',
    subtitle: 'Find nearby',
    route: 'center',
    gradient: [const Color(0xFF73A9E5), const Color(0xFF5B8FD4)],
    icon: Icons.location_on,
  ),
  CardModel(
    title: 'Volunteers',
    subtitle: 'Get support',
    route: 'volunteers',
    gradient: [const Color(0xFF7ABDE5), const Color(0xFF5BA4D4)],
    icon: MaterialCommunityIcons.hand_heart,
  ),
  CardModel(
    title: 'Profile',
    subtitle: 'Your health',
    route: 'profiling',
    gradient: [const Color(0xFF88D0E5), const Color(0xFF6BBDD4)],
    icon: Icons.person_search,
  ),
  CardModel(
    title: 'Resources',
    subtitle: 'Learn more',
    route: 'resources',
    gradient: [const Color(0xFF9C88E5), const Color(0xFF8570D4)],
    icon: Icons.library_books,
  ),
];
