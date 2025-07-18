import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextPrayerCard extends StatelessWidget {
  final String nextPrayerName;
  final DateTime? nextPrayerTime;

  const NextPrayerCard({
    Key? key,
    required this.nextPrayerName,
    this.nextPrayerTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeUntilPrayer = nextPrayerTime != null
        ? nextPrayerTime!.difference(DateTime.now())
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next Prayer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nextPrayerName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              if (nextPrayerTime != null) ...[
                Text(
                  DateFormat('h:mm a').format(nextPrayerTime!),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 4),
                if (timeUntilPrayer != null && timeUntilPrayer.inSeconds > 0)
                  Text(
                    'In ${_formatDuration(timeUntilPrayer)}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
