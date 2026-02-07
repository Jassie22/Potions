import 'package:flutter/material.dart';

class AboutDialogWidget extends StatelessWidget {
  const AboutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('About Potion Focus'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'A ritual-based focus and productivity application where each focus session creates a permanent potion artifact.',
            ),
            SizedBox(height: 16),
            Text(
              'Philosophy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Potion Focus replaces traditional productivity pressure with emotional, visual progression. No guilt-driven streaks, no competitive tracking—just a quiet personal archive of effort.',
            ),
            SizedBox(height: 16),
            Text(
              'Features',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• Focus timer with customizable durations\n'
                '• Potion collection with rarity system\n'
                '• Personalized daily and weekly quests\n'
                '• Recipe discovery through behavior\n'
                '• Essence economy for cosmetic unlocks\n'
                '• Offline-first architecture'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}



