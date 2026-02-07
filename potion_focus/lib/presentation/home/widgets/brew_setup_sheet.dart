import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_constants.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/presentation/home/widgets/bottle_selector.dart';
import 'package:potion_focus/presentation/home/widgets/liquid_selector.dart';
import 'package:potion_focus/presentation/home/widgets/tag_selector.dart';
import 'package:potion_focus/services/feedback_service.dart';
import 'package:potion_focus/services/timer_service.dart';

/// Bottom sheet for brew setup - contains duration, tags, and appearance selectors.
/// Opens when user taps "Start Brewing" on the clean home screen.
class BrewSetupSheet extends ConsumerStatefulWidget {
  final int initialDuration;
  final List<String> initialTags;
  final String initialBottle;
  final String initialLiquid;
  final bool initialIsFreeForm;
  final void Function(int duration, List<String> tags, String bottle, String liquid, {bool isFreeForm}) onStartBrewing;

  const BrewSetupSheet({
    super.key,
    required this.initialDuration,
    required this.initialTags,
    required this.initialBottle,
    required this.initialLiquid,
    this.initialIsFreeForm = false,
    required this.onStartBrewing,
  });

  @override
  ConsumerState<BrewSetupSheet> createState() => _BrewSetupSheetState();
}

class _BrewSetupSheetState extends ConsumerState<BrewSetupSheet> {
  late int _selectedDuration;
  late List<String> _selectedTags;
  late String _selectedBottle;
  late String _selectedLiquid;
  late bool _isFreeForm;
  bool _showAppearance = true;
  bool _showCustomDuration = false;
  final TextEditingController _customDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
    _selectedTags = List.from(widget.initialTags);
    _selectedBottle = widget.initialBottle;
    _selectedLiquid = widget.initialLiquid;
    _isFreeForm = widget.initialIsFreeForm;
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  bool get _canStartBrewing => _selectedTags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: const Border(
          top: BorderSide(color: Colors.black87, width: 3),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Duration section
              _buildSectionHeader('Duration', required: false),
              const SizedBox(height: 12),
              _buildDurationSelector(),
              const SizedBox(height: 24),

              // Tags section (required)
              _buildSectionHeader('Focus Tags', required: true),
              const SizedBox(height: 8),

              // Tag validation warning
              if (_selectedTags.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.warning, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select at least one focus tag to start',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              TagSelector(
                selectedTags: _selectedTags,
                onTagsChanged: (tags) {
                  setState(() => _selectedTags = tags);
                },
              ),
              const SizedBox(height: 24),

              // Appearance section (collapsible)
              _buildAppearanceSection(),
              const SizedBox(height: 32),

              // Begin Brewing button
              SizedBox(
                width: double.infinity,
                child: _buildBeginBrewingButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool required = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        if (required)
          Text(
            ' *',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.warning,
                ),
          ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...AppConstants.timerPresets.map((duration) =>
              _buildDurationChip(duration, !_isFreeForm && _selectedDuration == duration),
            ),
            _buildCustomDurationChip(),
            _buildFreeFormChip(),
          ],
        ),
        if (_showCustomDuration) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    hintText: '${AppConstants.minCustomDuration}-${AppConstants.maxCustomDuration}',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _applyCustomDuration(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _applyCustomDuration,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showCustomDuration = false),
              ),
            ],
          ),
        ],
        if (_isFreeForm) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.epic.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.epic, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.all_inclusive, color: AppColors.epic, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Focus freely for up to ${freeFormMaxMinutes ~/ 60} hours. End anytime (min $freeFormMinMinutes min for a valid potion).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.epic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationChip(int duration, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(feedbackServiceProvider).haptic(HapticType.light);
        setState(() {
          _selectedDuration = duration;
          _isFreeForm = false;
          _showCustomDuration = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.black54,
            width: 2,
          ),
        ),
        child: Text(
          '$duration min',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildCustomDurationChip() {
    final isCustom = !_isFreeForm && !AppConstants.timerPresets.contains(_selectedDuration);

    return GestureDetector(
      onTap: () {
        ref.read(feedbackServiceProvider).haptic(HapticType.light);
        setState(() {
          _isFreeForm = false;
          _showCustomDuration = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCustom
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isCustom ? Colors.black87 : Colors.black54,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: 14,
              color: isCustom ? Colors.white : null,
            ),
            const SizedBox(width: 4),
            Text(
              isCustom ? '$_selectedDuration min' : 'Custom',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCustom ? Colors.white : null,
                    fontWeight: isCustom ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeFormChip() {
    return GestureDetector(
      onTap: () {
        ref.read(feedbackServiceProvider).haptic(HapticType.light);
        setState(() {
          _isFreeForm = true;
          _showCustomDuration = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isFreeForm
              ? AppColors.epic
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: _isFreeForm ? Colors.black87 : Colors.black54,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.all_inclusive,
              size: 14,
              color: _isFreeForm ? Colors.white : AppColors.epic,
            ),
            const SizedBox(width: 4),
            Text(
              'Free-Form',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _isFreeForm ? Colors.white : null,
                    fontWeight: _isFreeForm ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyCustomDuration() {
    final value = int.tryParse(_customDurationController.text);
    if (value != null &&
        value >= AppConstants.minCustomDuration &&
        value <= AppConstants.maxCustomDuration) {
      setState(() {
        _selectedDuration = value;
        _showCustomDuration = false;
      });
      _customDurationController.clear();
      ref.read(feedbackServiceProvider).haptic(HapticType.success);
    } else {
      ref.read(feedbackServiceProvider).haptic(HapticType.error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter ${AppConstants.minCustomDuration}-${AppConstants.maxCustomDuration} minutes',
          ),
        ),
      );
    }
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible header
        GestureDetector(
          onTap: () {
            ref.read(feedbackServiceProvider).haptic(HapticType.light);
            setState(() => _showAppearance = !_showAppearance);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _showAppearance ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Collapsible content
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bottle selector
                Text(
                  'Bottle',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                ),
                const SizedBox(height: 8),
                BottleSelector(
                  selectedBottle: _selectedBottle,
                  onBottleChanged: (bottle) {
                    setState(() => _selectedBottle = bottle);
                  },
                ),
                const SizedBox(height: 16),

                // Liquid selector
                Text(
                  'Liquid',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                ),
                const SizedBox(height: 8),
                LiquidSelector(
                  selectedLiquid: _selectedLiquid,
                  onLiquidChanged: (liquid) {
                    setState(() => _selectedLiquid = liquid);
                  },
                ),
              ],
            ),
          ),
          crossFadeState: _showAppearance
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildBeginBrewingButton() {
    final buttonText = _isFreeForm ? 'Start Free-Form Session' : 'Begin Brewing';
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: _canStartBrewing
          ? () {
              ref.read(feedbackServiceProvider).feedback(
                    sound: SoundType.sessionStart,
                    haptic: HapticType.medium,
                  );
              widget.onStartBrewing(
                _selectedDuration,
                _selectedTags,
                _selectedBottle,
                _selectedLiquid,
                isFreeForm: _isFreeForm,
              );
              Navigator.of(context).pop();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          // Stepped/banded gradient for pixel-art aesthetic (no smooth gradients)
          gradient: _canStartBrewing
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(primaryColor, Colors.white, 0.15)!,
                    Color.lerp(primaryColor, Colors.white, 0.15)!,
                    primaryColor,
                    primaryColor,
                    Color.lerp(primaryColor, Colors.black, 0.2)!,
                    Color.lerp(primaryColor, Colors.black, 0.2)!,
                  ],
                  stops: const [0.0, 0.33, 0.33, 0.66, 0.66, 1.0],
                )
              : null,
          color: _canStartBrewing ? null : Colors.grey.shade700,
          border: Border.all(
            color: _canStartBrewing ? Colors.black87 : Colors.black54,
            width: 3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science,
              color: _canStartBrewing ? Colors.white : Colors.grey.shade500,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              buttonText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _canStartBrewing ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the brew setup bottom sheet and returns the selected options.
Future<void> showBrewSetupSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int initialDuration,
  required List<String> initialTags,
  required String initialBottle,
  required String initialLiquid,
  bool initialIsFreeForm = false,
  required void Function(int duration, List<String> tags, String bottle, String liquid, {bool isFreeForm}) onStartBrewing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => BrewSetupSheet(
        initialDuration: initialDuration,
        initialTags: initialTags,
        initialBottle: initialBottle,
        initialLiquid: initialLiquid,
        initialIsFreeForm: initialIsFreeForm,
        onStartBrewing: onStartBrewing,
      ),
    ),
  );
}
