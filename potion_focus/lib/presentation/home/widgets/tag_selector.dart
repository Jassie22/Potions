import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_constants.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';

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
    final userTagNames = userTags.map((t) => t.tag).toList() as List<String>;

    setState(() {
      // Combine default tags and user tags, remove duplicates
      _allTags = {...AppConstants.defaultTags, ...userTagNames}.toList();
      _allTags.sort();
    });
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(widget.selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      if (newTags.length < AppConstants.maxTagsPerSession) {
        newTags.add(tag);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can select up to ${AppConstants.maxTagsPerSession} tags',
            ),
          ),
        );
        return;
      }
    }
    widget.onTagsChanged(newTags);
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim().toLowerCase();
    if (tag.isEmpty) return;

    if (_allTags.contains(tag)) {
      // If tag already exists, just select it
      _toggleTag(tag);
    } else {
      // Add new tag
      setState(() {
        _allTags.add(tag);
        _allTags.sort();
      });
      _toggleTag(tag);
    }

    _customTagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected count
        if (widget.selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${widget.selectedTags.length}/${AppConstants.maxTagsPerSession} selected',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),

        // Tag chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allTags.map((tag) {
            final isSelected = widget.selectedTags.contains(tag);
            return FilterChip(
              label: Text('#$tag'),
              selected: isSelected,
              onSelected: (_) => _toggleTag(tag),
              selectedColor: AppColors.primaryLight.withOpacity(0.3),
              checkmarkColor: AppColors.primaryLight,
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

