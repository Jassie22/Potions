import 'package:flutter/material.dart';
import 'package:potion_focus/core/config/app_constants.dart';
import 'package:potion_focus/core/theme/app_colors.dart';

class DurationSelector extends StatefulWidget {
  final int selectedDuration;
  final Function(int) onDurationChanged;

  const DurationSelector({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  bool _showCustomInput = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset durations
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...AppConstants.timerPresets.map(
              (duration) => _buildDurationChip(
                context,
                duration,
                widget.selectedDuration == duration,
              ),
            ),
            // Custom button
            _buildCustomButton(context),
          ],
        ),

        // Custom input
        if (_showCustomInput) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Custom Duration (minutes)',
                    hintText: '${AppConstants.minCustomDuration}-${AppConstants.maxCustomDuration}',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _applyCustomDuration,
                    ),
                  ),
                  onSubmitted: (_) => _applyCustomDuration(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showCustomInput = false;
                    _customController.clear();
                  });
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDurationChip(BuildContext context, int duration, bool isSelected) {
    return ChoiceChip(
      label: Text('$duration min'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.onDurationChanged(duration);
          setState(() {
            _showCustomInput = false;
          });
        }
      },
      selectedColor: AppColors.primaryLight.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primaryLight
            : Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context) {
    final isCustomSelected = !AppConstants.timerPresets.contains(widget.selectedDuration);

    return ChoiceChip(
      label: Text(isCustomSelected ? '${widget.selectedDuration} min' : 'Custom'),
      selected: isCustomSelected,
      onSelected: (selected) {
        setState(() {
          _showCustomInput = true;
        });
      },
      selectedColor: AppColors.secondaryLight.withOpacity(0.3),
      avatar: const Icon(Icons.edit, size: 16),
    );
  }

  void _applyCustomDuration() {
    final value = int.tryParse(_customController.text);
    if (value != null &&
        value >= AppConstants.minCustomDuration &&
        value <= AppConstants.maxCustomDuration) {
      widget.onDurationChanged(value);
      setState(() {
        _showCustomInput = false;
      });
      _customController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a duration between ${AppConstants.minCustomDuration} and ${AppConstants.maxCustomDuration} minutes',
          ),
        ),
      );
    }
  }
}



