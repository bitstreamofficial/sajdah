import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sajdah/models/prayer_model.dart';
import 'package:sajdah/services/prayer_service.dart';

class PrayerCard extends StatefulWidget {
  final Prayer prayer;

  const PrayerCard({Key? key, required this.prayer}) : super(key: key);

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  PrayerData? _prayerData;
  Timer? _timer;
  String _timeRemaining = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerData() async {
    try {
      final prayerService = PrayerService();
      final data = await prayerService.getTodaysPrayerTimes();
      if (mounted) {
        setState(() {
          _prayerData = data;
          _isLoading = false;
          _updateTimeRemaining();
        });
      }
    } catch (e) {
      print('Error loading prayer data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateTimeRemaining();
      }
    });
  }

  void _updateTimeRemaining() {
    if (_prayerData == null) return;

    final currentPrayer = _getCurrentPrayerTime();
    if (currentPrayer != null) {
      final remaining = _calculateTimeRemaining(currentPrayer.endTime);
      setState(() {
        _timeRemaining = remaining;
      });
    } else {
      // If no current prayer found, try to find the next prayer
      final nextPrayer = _getNextPrayerTime();
      if (nextPrayer != null) {
        final remaining = _calculateTimeToStart(nextPrayer.startTime);
        setState(() {
          _timeRemaining = remaining.toString();
        });
      } else {
        setState(() {
          _timeRemaining = 'N/A';
        });
      }
    }
  }

  PrayerTime? _getCurrentPrayerTime() {
    if (_prayerData == null) return null;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    print('Current time: $currentTime');
    print('Looking for prayer: ${widget.prayer.name}');
    
    // Find the specific prayer that matches the widget's prayer name
    final matchingPrayers = _prayerData!.prayerTimes.where((prayer) => 
        prayer.name.toLowerCase() == widget.prayer.name.toLowerCase()).toList();
    
    print('Found ${matchingPrayers.length} matching prayers');
    
    for (final prayer in matchingPrayers) {
      print('Checking prayer: ${prayer.name}, Start: ${prayer.startTime}, End: ${prayer.endTime}');
      
      if (_isTimeBetween(currentTime, prayer.startTime, prayer.endTime)) {
        print('Found current prayer: ${prayer.name}');
        return prayer;
      }
    }
    
    print('No current prayer found for ${widget.prayer.name}');
    return null;
  }

  // New method to get next prayer time for the specific prayer
  PrayerTime? _getNextPrayerTime() {
    if (_prayerData == null) return null;
    
    final now = DateTime.now();
    final currentTimeMinutes = now.hour * 60 + now.minute;
    
    // Find all instances of this prayer
    final matchingPrayers = _prayerData!.prayerTimes.where((prayer) => 
        prayer.name.toLowerCase() == widget.prayer.name.toLowerCase()).toList();
    
    // Find the next occurrence
    for (final prayer in matchingPrayers) {
      final prayerStartMinutes = _parseTime(_convertTo24Hour(prayer.startTime));
      
      if (prayerStartMinutes > currentTimeMinutes) {
        return prayer;
      }
    }
    
    // If no prayer found for today, it means the next occurrence is tomorrow
    return matchingPrayers.isNotEmpty ? matchingPrayers.first : null;
  }

  // New method to calculate time until prayer starts
  String _calculateTimeToStart(String startTime) {
    try {
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final currentMinutes = _parseTime(currentTime);
      final startMinutes = _parseTime(_convertTo24Hour(startTime));
      
      int remainingMinutes;
      if (startMinutes >= currentMinutes) {
        remainingMinutes = startMinutes - currentMinutes;
      } else {
        // Next day
        remainingMinutes = (1440 - currentMinutes) + startMinutes;
      }
      
      final hours = remainingMinutes ~/ 60;
      final minutes = remainingMinutes % 60;
      
      if (hours > 0) {
        return '${hours}hr & ${minutes} min';
      } else {
        return '${minutes} min';
      }
    } catch (e) {
      print('Error calculating time to start: $e');
      return 'N/A';
    }
  }

  bool _isTimeBetween(String current, String start, String end) {
    try {
      final currentMinutes = _parseTime(current);
      final startMinutes = _parseTime(_convertTo24Hour(start));
      final endMinutes = _parseTime(_convertTo24Hour(end));
      
      print('Time comparison - Current: $currentMinutes, Start: $startMinutes, End: $endMinutes');
      
      if (startMinutes <= endMinutes) {
        // Normal case (doesn't cross midnight)
        return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      } else {
        // Time range crosses midnight
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
      }
    } catch (e) {
      print('Error in _isTimeBetween: $e');
      return false;
    }
  }

  int _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      print('Error parsing time: $timeString, Error: $e');
      return 0;
    }
  }

  String _convertTo24Hour(String time12) {
    try {
      final parts = time12.trim().split(' ');
      if (parts.length != 2) {
        print('Invalid time format: $time12');
        return time12; // Return original if format is wrong
      }
      
      final timePart = parts[0].split(':');
      final period = parts[1].toUpperCase();
      
      if (timePart.length != 2) {
        print('Invalid time part format: ${parts[0]}');
        return time12; // Return original if format is wrong
      }
      
      int hours = int.parse(timePart[0]);
      final minutes = timePart[1];
      
      if (period == 'AM' && hours == 12) {
        hours = 0;
      } else if (period == 'PM' && hours != 12) {
        hours = hours + 12;
      }
      
      return '${hours.toString().padLeft(2, '0')}:$minutes';
    } catch (e) {
      print('Error converting to 24 hour: $time12, Error: $e');
      return time12; // Return original if conversion fails
    }
  }

  String _calculateTimeRemaining(String endTime) {
    try {
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      print('Calculating time remaining - Current: $currentTime, End: $endTime');
      
      final currentMinutes = _parseTime(currentTime);
      final endMinutes = _parseTime(_convertTo24Hour(endTime));
      
      int remainingMinutes;
      if (endMinutes >= currentMinutes) {
        remainingMinutes = endMinutes - currentMinutes;
      } else {
        // Next day
        remainingMinutes = (1440 - currentMinutes) + endMinutes;
      }
      
      final hours = remainingMinutes ~/ 60;
      final minutes = remainingMinutes % 60;
      
      if (hours > 0) {
        return '${hours}hr & ${minutes} min';
      } else {
        return '${minutes} min';
      }
    } catch (e) {
      print('Error calculating time remaining: $e');
      return 'N/A';
    }
  }

  String _formatGregorianDate() {
    if (_prayerData?.dateInfo.gregorian == null) return 'Loading...';
    
    final gregorian = _prayerData!.dateInfo.gregorian;
    final weekday = gregorian.weekday.en;
    final day = gregorian.day;
    final month = gregorian.month.en;
    final year = gregorian.year;
    
    return '$weekday, $day $month $year';
  }

  String _formatHijriDate() {
    if (_prayerData?.dateInfo.hijri == null) return 'Loading...';
    
    final hijri = _prayerData!.dateInfo.hijri;
    final day = hijri.day;
    final month = hijri.month.en;
    final year = hijri.year;
    
    return '$day $month $year';
  }

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
        shadowColor: widget.prayer.primaryColor.withOpacity(0.3),
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
                            _getPrayerBackgroundImage(widget.prayer.name),
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
                        _getPrayerOverlayColor(widget.prayer.name).withOpacity(0.3),
                        _getPrayerOverlayColor(widget.prayer.name).withOpacity(0.6),
                        _getPrayerOverlayColor(widget.prayer.name).withOpacity(0.8),
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

                    // Main content with flexible layout
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
                                      // Header - Flexible (now includes actual date)
                                      _buildHeader(isSmallScreen, isVerySmall),

                                      // Flexible spacer
                                      Flexible(
                                        flex: 1,
                                        child: SizedBox(
                                          height: isVerySmall ? 8 : 12,
                                        ),
                                      ),

                                      // Central prayer circle - Adaptive and flexible
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

                                      // Time remaining section with actual data
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

              // Date section (right side) - Now showing actual data
              if (!isVerySmall)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLoading ? 'Loading...' : _formatGregorianDate(),
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
                              _isLoading ? 'Loading...' : _formatHijriDate(),
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
    // Dynamic sizing based on available space
    final maxCircleSize = availableHeight * 0.55;
    final circleSize = isVerySmall
        ? (maxCircleSize < 160 ? maxCircleSize : 160.0)
        : (isSmallScreen
              ? (maxCircleSize < 180 ? maxCircleSize : 180.0)
              : (isMediumScreen
                    ? (maxCircleSize < 220 ? maxCircleSize : 220.0)
                    : (maxCircleSize < 260 ? maxCircleSize : 260.0)));

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
            color: Colors.white.withOpacity(0.2),
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

              // Prayer name
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
                _isLoading ? 'Loading...' : (_timeRemaining.isEmpty ? 'N/A' : _timeRemaining),
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
          color: Colors.white,
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
      widget.prayer.name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isVerySmall
            ? 14
            : (isSmallScreen
                  ? 18
                  : (isMediumScreen ? 18 : 24)),
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