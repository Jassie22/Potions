import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/presentation/home/widgets/timer_widget.dart';
import 'package:potion_focus/presentation/home/widgets/brew_setup_sheet.dart';
import 'package:potion_focus/presentation/home/widgets/completion_modal.dart';
import 'package:potion_focus/presentation/settings/settings_screen.dart';
import 'package:potion_focus/presentation/shared/painting/background_themes.dart';
import 'package:potion_focus/services/timer_service.dart';
import 'package:potion_focus/services/theme_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Persisted selections for the setup sheet
  int _selectedDuration = 25;
  List<String> _selectedTags = [];
  String _selectedBottle = 'bottle_round';
  String _selectedLiquid = 'liquid_0';
  bool _isFreeForm = false;

  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  void _openBrewSetupSheet() {
    showBrewSetupSheet(
      context: context,
      ref: ref,
      initialDuration: _selectedDuration,
      initialTags: _selectedTags,
      initialBottle: _selectedBottle,
      initialLiquid: _selectedLiquid,
      initialIsFreeForm: _isFreeForm,
      onStartBrewing: (duration, tags, bottle, liquid, {bool isFreeForm = false}) {
        setState(() {
          _selectedDuration = duration;
          _selectedTags = tags;
          _selectedBottle = bottle;
          _selectedLiquid = liquid;
          _isFreeForm = isFreeForm;
        });
        if (isFreeForm) {
          ref.read(timerServiceProvider.notifier).startFreeFormSession(
                tags,
                selectedBottle: bottle,
                selectedLiquid: liquid,
              );
        } else {
          ref.read(timerServiceProvider.notifier).startTimer(
                Duration(minutes: duration),
                tags,
                selectedBottle: bottle,
                selectedLiquid: liquid,
              );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerServiceProvider);
    final activeTheme = ref.watch(activeThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Potion Focus',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
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
          // Background theme
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                final themeId = activeTheme.valueOrNull ?? 'theme_default';
                return CustomPaint(
                  painter: BackgroundThemePainter(
                    themeId: themeId,
                    animationValue: _bgAnimController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Main content - simplified clean layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // Header text (only when not brewing)
                  if (!timerState.isRunning) ...[
                    Text(
                      'Brew a Potion',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Focus deeply, create beautifully',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Timer widget (potion bottle + timer + controls)
                  TimerWidget(
                    duration: Duration(minutes: _selectedDuration),
                    selectedTags: _selectedTags,
                    selectedBottle: _selectedBottle,
                    selectedLiquid: _selectedLiquid,
                    onStartPressed: _openBrewSetupSheet,
                  ),

                  const Spacer(flex: 2),
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
