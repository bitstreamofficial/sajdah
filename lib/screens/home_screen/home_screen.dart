import 'package:flutter/material.dart';
import 'package:sajdah/models/prayer_model.dart';
import 'package:sajdah/screens/home_screen/prayer_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Prayer data with beautiful gradient colors
  final List<Prayer> prayers = [
    Prayer(
      name: 'Fajr',
      arabicName: 'الفجر',
      time: '5:30 AM',
      primaryColor: Color(0xFF4A90E2),
      secondaryColor: Color(0xFF6BB6FF),
      icon: Icons.wb_sunny_outlined,
      quote:
          'The early morning prayer brings light to your day and peace to your heart.',
    ),
    Prayer(
      name: 'Dhuhr',
      arabicName: 'الظهر',
      time: '12:15 PM',
      primaryColor: Color(0xFFE67E22),
      secondaryColor: Color(0xFFFF9A56),
      icon: Icons.wb_sunny,
      quote: 'Pause in the middle of your day to connect with the Divine.',
    ),
    Prayer(
      name: 'Asr',
      arabicName: 'العصر',
      time: '3:45 PM',
      primaryColor: Color(0xFFF39C12),
      secondaryColor: Color(0xFFFFB347),
      icon: Icons.wb_sunny_outlined,
      quote:
          'The afternoon prayer reminds us to be grateful for our blessings.',
    ),
    Prayer(
      name: 'Maghrib',
      arabicName: 'المغرب',
      time: '6:20 PM',
      primaryColor: Color(0xFFE74C3C),
      secondaryColor: Color(0xFFFF6B6B),
      icon: Icons.wb_twilight,
      quote:
          'As the sun sets, let your worries fade and your faith strengthen.',
    ),
    Prayer(
      name: 'Isha',
      arabicName: 'العشاء',
      time: '8:00 PM',
      primaryColor: Color(0xFF8E44AD),
      secondaryColor: Color(0xFFB19CD9),
      icon: Icons.bedtime,
      quote: 'End your day with gratitude and prepare your soul for rest.',
    ),
  ];

  late List<SwipeItem> swipeItems;
  late MatchEngine matchEngine;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSwipeItems();
  }

  void _initializeSwipeItems() {
    // Initialize swipe items only for untracked prayers
    final unTrackedPrayers = prayers
        .where((prayer) => !prayer.isTracked)
        .toList();

    swipeItems = unTrackedPrayers.map((prayer) {
      return SwipeItem(
        content: prayer,
        likeAction: () {
          _handleSwipeAction(prayer, true); // Right swipe = liked/prayed
        },
        nopeAction: () {
          _handleSwipeAction(prayer, false); // Left swipe = nope/missed
        },
      );
    }).toList();

    // Initialize match engine
    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  // Handle swipe actions and show feedback
  void _handleSwipeAction(Prayer prayer, bool isPrayed) {
    setState(() {
      prayer.isPrayed = isPrayed;
      prayer.isTracked = true;
      // Do NOT reinitialize swipeItems here, let SwipeCards handle the stack
    });

    // Show confirmation snackbar
    String actionText = isPrayed ? 'prayed ✅' : 'missed ❌';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked ${prayer.name} as $actionText'),
        backgroundColor: isPrayed ? Colors.green : Colors.orange,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  int get trackedPrayers => prayers.where((p) => p.isTracked).length;
  int get prayedCount => prayers.where((p) => p.isPrayed && p.isTracked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with title and progress
              // _buildHeader(),

              // Upper half - Swipe cards
              Container(
                height: 400, // Fixed height for swipe cards
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: swipeItems.isNotEmpty
                    ? SwipeCards(
                        matchEngine: matchEngine,
                        itemBuilder: (context, index) {
                          return PrayerCard(
                            prayer: swipeItems[index].content as Prayer,
                          );
                        },
                        onStackFinished: () {
                          setState(() {}); // Refresh UI when all cards are done
                        },
                        itemChanged: (SwipeItem item, int index) {
                          // Update current index when card changes
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        leftSwipeAllowed: true,
                        rightSwipeAllowed: true,
                        upSwipeAllowed: false,
                        fillSpace: false,
                      )
                    : _buildAllCompletedCard(),
              ),

              // Action buttons (only show if there are cards to swipe)
              // if (swipeItems.isNotEmpty) _buildActionButtons(),

              // Lower half - Habit tracker
              _buildHabitTracker(),
            ],
          ),
        ),
      ),
    );
  }

  // Header widget with title and progress indicator
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Daily Prayer Tracker',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          if (swipeItems.isNotEmpty)
            Text(
              'Swipe right if you prayed, left if you missed',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          SizedBox(height: 16),
          // Overall progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tracked: $trackedPrayers / ${prayers.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // All prayers completed card
  Widget _buildAllCompletedCard() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'All prayers tracked!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 207, 61, 61),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check your habit tracker below',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(
                      255,
                      153,
                      81,
                      81,
                    ).withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Habit tracker section
  Widget _buildHabitTracker() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tracker header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prayer Tracker',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: prayedCount == trackedPrayers && trackedPrayers > 0
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: prayedCount == trackedPrayers && trackedPrayers > 0
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  '$prayedCount/$trackedPrayers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: prayedCount == trackedPrayers && trackedPrayers > 0
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Progress bar
          if (trackedPrayers > 0)
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                widthFactor: prayedCount / trackedPrayers,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

          SizedBox(height: 28),

          // Prayer list with status
          ...prayers.map((prayer) => _buildPrayerHabitItem(prayer)).toList(),

          // Reset button
          if (trackedPrayers > 0)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (var prayer in prayers) {
                      prayer.isPrayed = false;
                      prayer.isTracked = false;
                    }
                    currentIndex = 0;
                    _initializeSwipeItems();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Reset Today\'s Tracker',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
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

  // Individual prayer habit item
  Widget _buildPrayerHabitItem(Prayer prayer) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!prayer.isTracked) {
      statusColor = Colors.black38;
      statusIcon = Icons.circle_outlined;
      statusText = 'Not tracked';
    } else if (prayer.isPrayed) {
      statusColor = Colors.green.shade600;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Completed';
    } else {
      statusColor = Colors.red.shade500;
      statusIcon = Icons.cancel_rounded;
      statusText = 'Missed';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              // Prayer icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [prayer.primaryColor, prayer.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: prayer.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(prayer.icon, color: Colors.white, size: 24),
              ),

              SizedBox(width: 16),

              // Prayer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          prayer.arabicName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(fontSize: 15, color: Colors.black26),
                        ),
                        Text(
                          prayer.time,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
