import 'dart:math' as math;

import 'package:flutter/material.dart';

class QiblaFinderScreen extends StatefulWidget {
  @override
  _QiblaFinderScreenState createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  double _qiblaDirection = 257.0; // Example direction

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5E6D3), Color(0xFFE8D5C4)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'QIBLA FINDER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50),

            // Compass
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Direction indicator
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.brown[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mosque, color: Colors.white, size: 20),
                    ),

                    SizedBox(height: 20),

                    // Compass Circle
                    Container(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Compass background
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                          ),

                          // Cardinal directions
                          Positioned(
                            top: 10,
                            child: Text(
                              'N',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: Text(
                              'W',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: Text(
                              'E',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                              ),
                            ),
                          ),

                          // Qibla direction needle
                          Transform.rotate(
                            angle: (_qiblaDirection * math.pi) / 180,
                            child: Container(
                              width: 4,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Center dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.brown[800],
                              shape: BoxShape.circle,
                            ),
                          ),

                          // Compass markings
                          ...List.generate(72, (index) {
                            final angle = (index * 5) * math.pi / 180;
                            final isMainDirection = index % 18 == 0;
                            return Transform.rotate(
                              angle: angle,
                              child: Container(
                                width: 2,
                                height: isMainDirection ? 20 : 10,
                                margin: EdgeInsets.only(
                                  top: isMainDirection ? 0 : 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.brown[300],
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Direction info
                    Text(
                      '${_qiblaDirection.toStringAsFixed(0)}°',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Device\'s angle to qibla',
                      style: TextStyle(fontSize: 14, color: Colors.brown[600]),
                    ),

                    SizedBox(height: 30),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rotate the phone 135° to the left',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
