import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sajdah/screens/main_screen.dart';
import 'dart:math' as math;

import 'package:sajdah/screens/qibla_finder_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic Prayer App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'SF Pro Display',
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
