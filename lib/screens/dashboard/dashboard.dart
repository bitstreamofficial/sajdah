import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

// Prayer model class
class Prayer {
  final String name;
  final String arabicName;
  final String time;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String quote;

  Prayer({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.quote,
  });
}

class PrayerSwipeScreen extends StatefulWidget {
  @override
  _PrayerSwipeScreenState createState() => _PrayerSwipeScreenState();
}

class _PrayerSwipeScreenState extends State<PrayerSwipeScreen> {
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
    // Initialize swipe items from prayer data
    swipeItems = prayers.map((prayer) {
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
      currentIndex++;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title and progress
              _buildHeader(),

              // Main swipe cards area
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: currentIndex < prayers.length
                      ? SwipeCards(
                          matchEngine: matchEngine,
                          itemBuilder: (context, index) {
                            return PrayerCard(
                              prayer: swipeItems[index].content as Prayer,
                            );
                          },
                          onStackFinished: () {
                            // All cards swiped
                            _showCompletionDialog();
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
                      : _buildCompletionScreen(),
                ),
              ),

              // Action buttons and instructions
              _buildActionButtons(),
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
          Text(
            'Swipe right if you prayed, left if you missed',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),
          // Progress indicator
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
                  '${currentIndex + 1} / ${prayers.length}',
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

  // Action buttons at the bottom
  Widget _buildActionButtons() {
    if (currentIndex >= prayers.length) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Miss button (left swipe)
          FloatingActionButton(
            heroTag: "miss",
            onPressed: () {
              matchEngine.currentItem?.nope();
            },
            backgroundColor: Colors.red,
            elevation: 4,
            child: Icon(Icons.close, color: Colors.white, size: 28),
          ),

          // Prayed button (right swipe)
          FloatingActionButton(
            heroTag: "prayed",
            onPressed: () {
              matchEngine.currentItem?.like();
            },
            backgroundColor: Colors.green,
            elevation: 4,
            child: Icon(Icons.check, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // Completion screen when all prayers are reviewed
  Widget _buildCompletionScreen() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 60, color: Colors.green),
          ),
          SizedBox(height: 24),
          Text(
            'All prayers reviewed!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'You\'ve completed today\'s prayer tracking.\nMay your prayers be accepted.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Reset the app
              setState(() {
                currentIndex = 0;
                swipeItems = prayers.map((prayer) {
                  return SwipeItem(
                    content: prayer,
                    likeAction: () => _handleSwipeAction(prayer, true),
                    nopeAction: () => _handleSwipeAction(prayer, false),
                  );
                }).toList();
                matchEngine = MatchEngine(swipeItems: swipeItems);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Show completion dialog
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 60, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ve reviewed all your prayers for today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Prayer card widget with beautiful design
class PrayerCard extends StatelessWidget {
  final Prayer prayer;

  const PrayerCard({Key? key, required this.prayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [prayer.primaryColor, prayer.secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: prayer.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Prayer icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(prayer.icon, size: 40, color: Colors.white),
                    ),

                    SizedBox(height: 24),

                    // Arabic name
                    Text(
                      prayer.arabicName,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    // English name
                    Text(
                      prayer.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Time container
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            prayer.time,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Motivational quote
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        prayer.quote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Swipe indicators (shown during drag)
              Positioned(
                top: 50,
                left: 50,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),

              Positioned(
                top: 50,
                right: 50,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
