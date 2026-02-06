import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_constants.dart';
import 'package:potion_focus/core/errors/app_error.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/presentation/shared/widgets/error_snackbar.dart';
import 'package:potion_focus/services/feedback_service.dart';

/// Tag data with name and color
class TagInfo {
  final String name;
  final int colorIndex;

  const TagInfo(this.name, this.colorIndex);

  Color get color => AppColors.getTagColor(colorIndex);
}

class TagSelector extends ConsumerStatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends ConsumerState<TagSelector> {
  final TextEditingController _customTagController = TextEditingController();
  Map<String, TagInfo> _tagInfoMap = {};
  List<String> _allTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final db = DatabaseHelper.instance;
    final userTags = await db.tagStatsModels.getAllItems();

    // Build tag info map with colors
    final Map<String, TagInfo> tagMap = {};

    // Add user tags with their colors
    for (final tag in userTags) {
      tagMap[tag.tag] = TagInfo(tag.tag, tag.colorIndex);
    }

    setState(() {
      _tagInfoMap = tagMap;
      _allTags = tagMap.keys.toList()..sort();
    });
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(widget.selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
      ref.read(feedbackServiceProvider).haptic(HapticType.light);
    } else {
      if (newTags.length < AppConstants.maxTagsPerSession) {
        newTags.add(tag);
        ref.read(feedbackServiceProvider).haptic(HapticType.light);
      } else {
        ref.read(feedbackServiceProvider).haptic(HapticType.error);
        showErrorSnackbar(
          context,
          AppErrors.tagLimitReached(AppConstants.maxTagsPerSession),
        );
        return;
      }
    }
    widget.onTagsChanged(newTags);
  }

  Future<void> _addCustomTag() async {
    final tag = _customTagController.text.trim().toLowerCase();
    if (tag.isEmpty) return;

    if (_allTags.contains(tag)) {
      // If tag already exists, just select it
      _toggleTag(tag);
    } else {
      // Add new tag with a random color
      final colorIndex = tag.hashCode.abs() % AppColors.tagColors.length;

      // Save to database
      final db = DatabaseHelper.instance;
      final newTagModel = TagStatsModel(tag: tag, colorIndex: colorIndex);
      await db.writeTxn(() async {
        await db.tagStatsModels.put(newTagModel);
      });

      setState(() {
        _tagInfoMap[tag] = TagInfo(tag, colorIndex);
        _allTags = _tagInfoMap.keys.toList()..sort();
      });
      _toggleTag(tag);
    }

    _customTagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.selectedTags.length;
    final maxTags = AppConstants.maxTagsPerSession;
    final isAtLimit = selectedCount >= maxTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Focus Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAtLimit
                    ? AppColors.warning.withOpacity(0.15)
                    : AppColors.primaryLight.withOpacity(0.1),
                border: Border.all(
                  color: isAtLimit
                      ? AppColors.warning.withOpacity(0.5)
                      : AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
              child: Text(
                '$selectedCount/$maxTags',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isAtLimit ? AppColors.warning : AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _allTags.isEmpty
              ? 'Create your first tag below'
              : selectedCount == 0
                  ? 'Select at least one tag to start brewing'
                  : isAtLimit
                      ? 'Maximum tags selected'
                      : 'Select tags to categorize your session',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: (selectedCount == 0 || _allTags.isEmpty) ? FontStyle.italic : FontStyle.normal,
              ),
        ),
        const SizedBox(height: 12),

        // Tag chips with colors
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allTags.map((tag) {
            final isSelected = widget.selectedTags.contains(tag);
            final isDisabled = !isSelected && isAtLimit;
            final tagInfo = _tagInfoMap[tag];
            final tagColor = tagInfo?.color ?? AppColors.tagColors[0];

            return Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: isDisabled ? null : () => _toggleTag(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? tagColor.withOpacity(0.3) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? tagColor : Colors.grey.shade400,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Color indicator dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: tagColor,
                          border: Border.all(color: Colors.black54, width: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected ? tagColor : null,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.check, size: 14, color: tagColor),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Custom tag input
        TextField(
          controller: _customTagController,
          decoration: InputDecoration(
            labelText: 'Add custom tag',
            hintText: 'e.g., project-name',
            prefixIcon: const Icon(Icons.label_outline),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCustomTag,
            ),
          ),
          onSubmitted: (_) => _addCustomTag(),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
