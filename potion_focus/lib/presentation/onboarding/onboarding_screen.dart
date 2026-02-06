import 'package:flutter/material.dart';
import 'package:potion_focus/core/config/app_preferences.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/presentation/shared/app_navigation.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'package:potion_focus/presentation/shared/painting/background_themes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
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
    _pageController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await AppPreferences.setHasCompletedOnboarding(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundThemePainter(
                    themeId: 'theme_default',
                    animationValue: _bgAnimController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildStep1Page(),
                      _buildStep2Page(),
                      _buildStep3Page(),
                      _buildStep4Page(),
                      _buildFinalPage(),
                    ],
                  ),
                ),

                // Page indicator (pixel squares)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => _buildDot(index == _currentPage),
                  ),
                ),
                const SizedBox(height: 24),

                // Next/Get Started button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: BorderSide(
                          color: AppColors.mysticalGold.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _currentPage == 5 ? 'Start Brewing' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Welcome page
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PotionRenderer(
            config: const VisualConfig(
              bottleShape: 'bottle_round',
              liquid: 'liquid_0',
              effectType: 'effect_glow',
              rarity: 'uncommon',
            ),
            size: 160,
            fillPercent: 1.0,
            isBrewing: false,
            showGlow: true,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome, Alchemist',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Turn your focus time into beautiful potions. Let me show you how it works.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Step 1: Set your duration
  Widget _buildStep1Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step indicator
          _buildStepIndicator(1),
          const SizedBox(height: 24),
          // Duration pills mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              border: Border.all(color: AppColors.mysticalGold.withOpacity(0.3), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDurationChip('15', false),
                const SizedBox(width: 8),
                _buildDurationChip('25', true),
                const SizedBox(width: 8),
                _buildDurationChip('45', false),
                const SizedBox(width: 8),
                _buildDurationChip('60', false),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Choose Duration',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Pick how long you want to focus. Start with 25 minutes — the classic Pomodoro length.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Step 2: Add focus tags
  Widget _buildStep2Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(2),
          const SizedBox(height: 24),
          // Tags mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              border: Border.all(color: AppColors.mysticalGold.withOpacity(0.3), width: 2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildTagChip('Work', true),
                _buildTagChip('Study', false),
                _buildTagChip('Creative', true),
                _buildTagChip('Reading', false),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Tag Your Focus',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Select at least one tag to track what you\'re working on. This helps you see patterns over time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Step 3: Pick your bottle and liquid
  Widget _buildStep3Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(3),
          const SizedBox(height: 24),
          // Bottles row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBottleOption('bottle_round', 'liquid_0', false),
              const SizedBox(width: 12),
              _buildBottleOption('bottle_tall', 'liquid_1', true),
              const SizedBox(width: 12),
              _buildBottleOption('bottle_flask', 'liquid_4', false),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Customize Your Brew',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a bottle shape and liquid color. Your potion will fill as you focus. Tilt your phone to slosh the liquid!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Step 4: Brew and watch it fill
  Widget _buildStep4Page() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(4),
          const SizedBox(height: 24),
          // Brewing potion animation
          PotionRenderer(
            config: const VisualConfig(
              bottleShape: 'bottle_potion',
              liquid: 'liquid_4',
              effectType: 'none',
              rarity: 'common',
            ),
            size: 140,
            fillPercent: 0.65,
            isBrewing: true,
            showGlow: true,
          ),
          const SizedBox(height: 32),
          Text(
            'Watch It Brew',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Press Start and focus. Your potion fills as time passes. Complete the session to add it to your collection!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Final page: Unlock & collect
  Widget _buildFinalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row of rarity potions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PotionRenderer(
                config: const VisualConfig(
                  bottleShape: 'bottle_round',
                  liquid: 'liquid_9',
                  effectType: 'effect_sparkles',
                  rarity: 'rare',
                ),
                size: 80,
                fillPercent: 1.0,
                showGlow: true,
              ),
              const SizedBox(width: 8),
              PotionRenderer(
                config: const VisualConfig(
                  bottleShape: 'bottle_potion',
                  liquid: 'liquid_14',
                  effectType: 'effect_smoke',
                  rarity: 'epic',
                ),
                size: 100,
                fillPercent: 1.0,
                showGlow: true,
              ),
              const SizedBox(width: 8),
              PotionRenderer(
                config: const VisualConfig(
                  bottleShape: 'bottle_legendary',
                  liquid: 'liquid_18',
                  effectType: 'effect_legendary_glow',
                  rarity: 'legendary',
                ),
                size: 80,
                fillPercent: 1.0,
                showGlow: true,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Unlock & Collect',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Discover 21 unique liquids in the Grimoire. From common brews to legendary elixirs — each unlocked through dedication.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mysticalGold.withOpacity(0.15),
              border: Border.all(color: AppColors.mysticalGold.withOpacity(0.4), width: 2),
            ),
            child: Text(
              'No guilt, no pressure.\nJust a quiet archive of effort.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mysticalGold,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        border: Border.all(color: AppColors.primaryLight, width: 2),
      ),
      child: Text(
        'STEP $step',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
      ),
    );
  }

  Widget _buildDurationChip(String minutes, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryLight : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primaryLight : Colors.white38,
          width: 2,
        ),
      ),
      child: Text(
        '${minutes}m',
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.secondaryLight.withOpacity(0.3) : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.secondaryLight : Colors.white38,
          width: 2,
        ),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBottleOption(String bottle, String liquid, bool selected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryLight.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primaryLight : Colors.white24,
          width: 2,
        ),
      ),
      child: PotionRenderer(
        config: VisualConfig(
          bottleShape: bottle,
          liquid: liquid,
          effectType: 'none',
          rarity: 'common',
        ),
        size: 70,
        fillPercent: 0.7,
        showGlow: selected,
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        color: isActive ? AppColors.mysticalGold : Colors.white24,
      ),
    );
  }
}
