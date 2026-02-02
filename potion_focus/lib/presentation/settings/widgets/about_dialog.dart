import 'package:flutter/material.dart';

class AboutDialogWidget extends StatelessWidget {
  const AboutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('About Potion Focus'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A ritual-based focus and productivity application where each focus session creates a permanent potion artifact.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Philosophy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Potion Focus replaces traditional productivity pressure with emotional, visual progression. No guilt-driven streaks, no competitive tracking—just a quiet personal archive of effort.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Features',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('• Focus timer with customizable durations\n'
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



