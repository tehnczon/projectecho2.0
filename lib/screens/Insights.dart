import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class Insights extends StatelessWidget {
  const Insights({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryBox(),
          const SizedBox(height: 20),
          _barChartAge(),
          const SizedBox(height: 20),
          _pieChartGender(),
          const SizedBox(height: 20),
          _pieChartHIVStatus(),
          const SizedBox(height: 20),
          _textHighlights(),
        ],
      ),
    );
  }

  Widget _summaryBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Profiles', '47'),
          _stat('On ART', '38'),
          _stat('Aware U=U', '29'),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(title, style: GoogleFonts.lato(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _barChartAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Age Group Distribution", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const labels = ['18-24', '25-34', '35-44', '45+'];
                      return Text(labels[value.toInt()], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: Colors.blue)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 18, color: Colors.blue)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7, color: Colors.blue)]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pieChartGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender Identity", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              sections: [
                PieChartSectionData(value: 20, color: Colors.blue, title: 'Male'),
                PieChartSectionData(value: 15, color: Colors.pinkAccent, title: 'Trans'),
                PieChartSectionData(value: 8, color: Colors.purple, title: 'Female'),
                PieChartSectionData(value: 4, color: Colors.teal, title: 'Other'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pieChartHIVStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("HIV Status", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(value: 30, color: Colors.redAccent, title: 'Positive'),
                PieChartSectionData(value: 10, color: Colors.green, title: 'Negative'),
                PieChartSectionData(value: 7, color: Colors.grey, title: 'Prefer not to say'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _textHighlights() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text("📌 Key Insights", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            "Most respondents are aged 25–34.\nMajority identify as male or transgender.\nOver 80% are on ART.\nOnly 61% are aware of U=U.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
