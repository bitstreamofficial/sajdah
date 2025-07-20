// Prayer model class
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class Prayer {
  final String name;
  final String arabicName;
  final String time;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String quote;
  bool isPrayed;
  bool isTracked;

  Prayer({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.quote,
    this.isPrayed = false,
    this.isTracked = false,
  });
}
