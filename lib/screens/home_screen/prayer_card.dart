import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sajdah/models/prayer_model.dart';

class PrayerCard extends StatelessWidget {
  final Prayer prayer;

  const PrayerCard({Key? key, required this.prayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    final isMediumScreen = size.height < 700;
    final isVerySmall = size.height < 500;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Card(
        elevation: 12,
        shadowColor: prayer.primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
            child: Stack(
              children: [
                // Background image with blur effect
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            _getPrayerBackgroundImage(prayer.name),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Gradient overlay on top of blurred image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getPrayerOverlayColor(prayer.name).withOpacity(0.3),
                        _getPrayerOverlayColor(prayer.name).withOpacity(0.6),
                        _getPrayerOverlayColor(prayer.name).withOpacity(0.8),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Content stack
                Stack(
                  children: [
                    // Enhanced decorative elements
                    _buildDecorativeCircles(),

                    // Main content with flexible layout - FIXED OVERFLOW
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVerySmall
                              ? 12
                              : (isSmallScreen ? 16 : 20),
                          vertical: isVerySmall ? 8 : (isSmallScreen ? 10 : 12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableHeight = constraints.maxHeight;

                            return Container(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: availableHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    children: [
                                      // Header - Flexible (now includes date)
                                      _buildHeader(isSmallScreen, isVerySmall),

                                      // Flexible spacer
                                      Flexible(
                                        flex: 1,
                                        child: SizedBox(
                                          height: isVerySmall ? 8 : 12,
                                        ),
                                      ),

                                      // Central prayer circle - Adaptive and flexible (NO TIME REMAINING INSIDE)
                                      Flexible(
                                        flex: isVerySmall ? 6 : 8,
                                        child: Center(
                                          child: _buildPrayerCircle(
                                            isSmallScreen,
                                            isMediumScreen,
                                            isVerySmall,
                                            availableHeight,
                                          ),
                                        ),
                                      ),

                                      // Flexible spacer
                                      Flexible(
                                        flex: 1,
                                        child: SizedBox(
                                          height: isVerySmall ? 6 : 12,
                                        ),
                                      ),

                                      // Time remaining section - NEW INDEPENDENT SECTION
                                      _buildTimeRemainingSection(
                                        isSmallScreen,
                                        isVerySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPrayerBackgroundImage(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'assets/images/fajr.png';
      case 'dhuhr':
        return 'assets/images/dhuhr.png';
      case 'asr':
        return 'assets/images/asr.png';
      case 'maghrib':
        return 'assets/images/maghrib.png';
      case 'isha':
        return 'assets/images/isha.png';
      default:
        return 'assets/images/default_bg.jpg';
    }
  }

  Color _getPrayerOverlayColor(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Color(0xFF4A90E2);
      case 'dhuhr':
        return Color(0xFFFF8C00);
      case 'asr':
        return Color(0xFFFFB347);
      case 'maghrib':
        return Color(0xFFE74C3C);
      case 'isha':
        return Color(0xFF2C3E50);
      default:
        return Color(0xFF34495E);
    }
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // Top right large circle
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        // Top right small circle
        Positioned(
          top: 80,
          right: 30,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        // Bottom left circle
        Positioned(
          bottom: -50,
          left: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        // Bottom right small circle
        Positioned(
          bottom: 100,
          right: 20,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        // Additional geometric shapes for more visual interest
        Positioned(
          top: 120,
          left: 40,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
      child: Column(
        children: [
          // Main row - Location on left, Date on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location section (left side)
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isVerySmall ? 4 : 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          isVerySmall ? 6 : 10,
                        ),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: isVerySmall ? 12 : (isSmallScreen ? 14 : 16),
                      ),
                    ),
                    SizedBox(width: isVerySmall ? 6 : 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Dhaka, BD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isVerySmall
                                  ? 11
                                  : (isSmallScreen ? 12 : 14),
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          if (!isVerySmall && !isSmallScreen)
                            Text(
                              'Your Location',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Date section (right side)
              if (!isVerySmall)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Friday, 12 Sept 2024',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 11 : 13,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      if (!isSmallScreen)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 1),
                            Text(
                              '9 Rabi 1445',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCircle(
    bool isSmallScreen,
    bool isMediumScreen,
    bool isVerySmall,
    double availableHeight,
  ) {
    // Dynamic sizing based on available space - made bigger
    final maxCircleSize =
        availableHeight * 0.55; // Increased from 0.45 to make it bigger
    final circleSize = isVerySmall
        ? (maxCircleSize < 160 ? maxCircleSize : 160.0) // Increased from 140
        : (isSmallScreen
              ? (maxCircleSize < 180
                    ? maxCircleSize
                    : 180.0) // Increased from 160
              : (isMediumScreen
                    ? (maxCircleSize < 220
                          ? maxCircleSize
                          : 220.0) // Increased from 190
                    : (maxCircleSize < 260
                          ? maxCircleSize
                          : 260.0))); // Increased from 220

    final innerCircleSize = circleSize * 0.75;

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: isVerySmall ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(
              0.2,
            ), // Changed from black to white for lightish blur
            blurRadius: isVerySmall ? 15 : 25,
            offset: Offset(0, isVerySmall ? 5 : 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerCircleSize,
          height: innerCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prayer image instead of icon
              _buildPrayerImage(isSmallScreen, isVerySmall),

              // Prayer name - now with more space
              _buildPrayerName(isSmallScreen, isMediumScreen, isVerySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRemainingSection(bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isVerySmall ? 10 : (isSmallScreen ? 12 : 14),
        horizontal: isVerySmall ? 16 : (isSmallScreen ? 18 : 24),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isVerySmall ? 18 : 22),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: isVerySmall ? 8 : 12,
            offset: Offset(0, isVerySmall ? 3 : 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isVerySmall ? 6 : (isSmallScreen ? 8 : 10)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isVerySmall ? 8 : 12),
            ),
            child: Icon(
              Icons.access_time,
              color: Colors.white,
              size: isVerySmall ? 16 : (isSmallScreen ? 18 : 20),
            ),
          ),
          SizedBox(width: isVerySmall ? 10 : (isSmallScreen ? 12 : 16)),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1hr & 33 min',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isVerySmall ? 14 : (isSmallScreen ? 16 : 18),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
              Text(
                'Time Remaining',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isVerySmall ? 10 : (isSmallScreen ? 11 : 12),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New method to build prayer image instead of icon
  Widget _buildPrayerImage(bool isSmallScreen, bool isVerySmall) {
    final imageSize = isVerySmall ? 32.0 : (isSmallScreen ? 38.0 : 46.0);
    final imageContainerSize = isVerySmall
        ? 56.0
        : (isSmallScreen ? 56.0 : 65.0);

    return Container(
      width: imageContainerSize,
      height: imageContainerSize,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageContainerSize / 2),
        child: Image.asset(
          'assets/images/sajdah.png',
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
          color: Colors
              .white, // This will tint the image white if it's a monochrome image
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildPrayerName(
    bool isSmallScreen,
    bool isMediumScreen,
    bool isVerySmall,
  ) {
    return Text(
      prayer.name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isVerySmall
            ? 14 // Increased since more space available
            : (isSmallScreen
                  ? 18
                  : (isMediumScreen ? 18 : 24)), // Increased sizes
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.8,
        shadows: [
          Shadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
