import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/presentation/home/widgets/timer_widget.dart';
import 'package:potion_focus/presentation/home/widgets/duration_selector.dart';
import 'package:potion_focus/presentation/home/widgets/tag_selector.dart';
import 'package:potion_focus/presentation/home/widgets/completion_modal.dart';
import 'package:potion_focus/presentation/settings/settings_screen.dart';
import 'package:potion_focus/services/timer_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedDuration = 25; // Default 25 minutes
  List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerServiceProvider);

    // Listen for completed potion to show modal
    ref.listen<TimerState>(timerServiceProvider, (prev, next) {
      if (prev?.completedPotion == null && next.completedPotion != null) {
        // Potion just completed -- show modal
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Potion Focus',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brewing area
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            'Brew a Potion',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Focus deeply, create beautifully',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 32),
                          TimerWidget(
                            duration: Duration(minutes: _selectedDuration),
                            selectedTags: _selectedTags,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Duration selector (hide while brewing)
                  if (!timerState.isRunning) ...[
                    Text(
                      'Duration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    DurationSelector(
                      selectedDuration: _selectedDuration,
                      onDurationChanged: (duration) {
                        setState(() {
                          _selectedDuration = duration;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tag selector
                    Text(
                      'Focus Tags',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TagSelector(
                      selectedTags: _selectedTags,
                      onTagsChanged: (tags) {
                        setState(() {
                          _selectedTags = tags;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Completion modal overlay
          if (timerState.completedPotion != null)
            CompletionModal(
              potion: timerState.completedPotion!,
              onDismiss: () {
                ref.read(timerServiceProvider.notifier).clearCompletedPotion();
              },
            ),
        ],
      ),
    );
  }
}
