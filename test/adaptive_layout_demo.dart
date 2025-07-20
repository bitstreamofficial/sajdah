import 'package:flutter/material.dart';
import 'package:sajdah/models/prayer_model.dart';
import 'package:sajdah/screens/home_screen/prayer_card.dart';

void main() {
  runApp(AdaptiveLayoutDemo());
}

class AdaptiveLayoutDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Card Adaptive Layout Demo',
      home: AdaptiveLayoutScreen(),
    );
  }
}

class AdaptiveLayoutScreen extends StatelessWidget {
  final Prayer testPrayer = Prayer(
    name: 'Fajr',
    arabicName: 'الفجر',
    time: '5:30 AM',
    primaryColor: Colors.blue,
    secondaryColor: Colors.lightBlue,
    icon: Icons.wb_sunny,
    quote: 'Test quote',
    isPrayed: false,
    isTracked: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Card Adaptive Layout Demo'),
      ),
      body: Column(
        children: [
          // Large screen demonstration
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                children: [
                  Text('Large Screen (800x600)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SizedBox(
                      height: 600,
                      width: 400,
                      child: PrayerCard(prayer: testPrayer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Medium screen demonstration
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                children: [
                  Text('Medium Screen (600x400)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SizedBox(
                      height: 400,
                      width: 350,
                      child: PrayerCard(prayer: testPrayer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Small screen demonstration
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                children: [
                  Text('Small Screen (400x300)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: PrayerCard(prayer: testPrayer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}