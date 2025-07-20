import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajdah/models/prayer_model.dart';
import 'package:sajdah/screens/home_screen/prayer_card.dart';

void main() {
  group('PrayerCard Adaptive Layout Tests', () {
    late Prayer testPrayer;

    setUp(() {
      testPrayer = Prayer(
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
    });

    testWidgets('PrayerCard shows all elements on large screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800, // Large screen height
              width: 400,
              child: PrayerCard(prayer: testPrayer),
            ),
          ),
        ),
      );

      // Verify essential elements are present
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Friday, 12 Sept 2024'), findsOneWidget);
      expect(find.text('9 Rabi 1445'), findsOneWidget); // Islamic date should be visible
      expect(find.byIcon(Icons.menu), findsOneWidget); // Menu icon should be visible
      expect(find.byIcon(Icons.volume_up_outlined), findsWidgets); // Volume icons should be visible
    });

    testWidgets('PrayerCard hides optional elements on small screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400, // Small screen height
              width: 300,
              child: PrayerCard(prayer: testPrayer),
            ),
          ),
        ),
      );

      // Verify essential elements are still present
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Friday, 12 Sept 2024'), findsOneWidget);
      
      // Verify optional elements are hidden
      expect(find.text('9 Rabi 1445'), findsNothing); // Islamic date should be hidden
      expect(find.byIcon(Icons.menu), findsNothing); // Menu icon should be hidden
      expect(find.byIcon(Icons.volume_up_outlined), findsNothing); // Volume icons should be hidden
    });

    testWidgets('PrayerCard shows important elements on medium screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600, // Medium screen height
              width: 350,
              child: PrayerCard(prayer: testPrayer),
            ),
          ),
        ),
      );

      // Verify essential and important elements are present
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Friday, 12 Sept 2024'), findsOneWidget);
      expect(find.text('9 Rabi 1445'), findsOneWidget); // Islamic date should be visible
      
      // Verify optional elements are hidden
      expect(find.byIcon(Icons.menu), findsNothing); // Menu icon should be hidden
      expect(find.byIcon(Icons.volume_up_outlined), findsNothing); // Volume icons should be hidden
    });

    testWidgets('PrayerCard shows only essential prayer times on small screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400, // Small screen height
              width: 300,
              child: PrayerCard(prayer: testPrayer),
            ),
          ),
        ),
      );

      // Essential prayer times should be visible
      expect(find.text('Fajr'), findsWidgets);
      expect(find.text('Dhuhr'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      
      // Important but non-essential times should be hidden
      expect(find.text('Suhoor'), findsNothing);
    });
  });
}