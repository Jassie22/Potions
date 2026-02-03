import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/services/feedback_service.dart';

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  Future<List<TagStatsModel>> _loadTags() async {
    final db = DatabaseHelper.instance;
    final tags = await db.tagStatsModels.getAllItems();
    tags.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));
    return tags;
  }

  Future<void> _editTagColor(TagStatsModel tag) async {
    final newColorIndex = await showDialog<int>(
      context: context,
      builder: (context) => _TagColorPickerDialog(
        tagName: tag.tag,
        currentColorIndex: tag.colorIndex,
      ),
    );

    if (newColorIndex != null && newColorIndex != tag.colorIndex) {
      final db = DatabaseHelper.instance;
      tag.colorIndex = newColorIndex;
      await db.writeTxn(() async {
        await db.tagStatsModels.put(tag);
      });

      ref.read(feedbackServiceProvider).haptic(HapticType.success);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Color updated for "${tag.tag}"')),
        );
        setState(() {}); // Refresh list
      }
    }
  }

  Future<void> _deleteTag(String tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag?'),
        content: Text(
          'Are you sure you want to delete "$tag"? This will not delete your sessions, but the tag will no longer appear in suggestions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = DatabaseHelper.instance;
      final allTags = await db.tagStatsModels.getAllItems();
      final tagStats = allTags.where((t) => t.tag == tag).firstOrNull;

      if (tagStats != null) {
        await db.writeTxn(() async {
          await db.tagStatsModels.delete(tagStats.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tag "$tag" deleted')),
          );
          setState(() {}); // Refresh list
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<TagStatsModel>>(
        future: _loadTags(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tags = snapshot.data ?? [];

          if (tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.label_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Tags Yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tags will appear here as you use them in sessions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final tagColor = AppColors.getTagColor(tag.colorIndex);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _editTagColor(tag),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.3),
                        border: Border.all(color: tagColor, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: tagColor,
                            border: Border.all(color: Colors.black54, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '#${tag.tag}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                    ),
                  ),
                  subtitle: Text(
                    '${tag.totalSessions} sessions • ${tag.totalMinutes} minutes',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.palette_outlined),
                        tooltip: 'Change color',
                        onPressed: () => _editTagColor(tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Delete tag',
                        onPressed: () => _deleteTag(tag.tag),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Dialog for picking a tag color from the preset palette
class _TagColorPickerDialog extends StatefulWidget {
  final String tagName;
  final int currentColorIndex;

  const _TagColorPickerDialog({
    required this.tagName,
    required this.currentColorIndex,
  });

  @override
  State<_TagColorPickerDialog> createState() => _TagColorPickerDialogState();
}

class _TagColorPickerDialogState extends State<_TagColorPickerDialog> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentColorIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Color for #${widget.tagName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select a color',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),

          // Color grid (4x3)
          SizedBox(
            width: 240,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(AppColors.tagColors.length, (index) {
                final color = AppColors.tagColors[index];
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.black38,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.black54, size: 24)
                        : null,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tagColors[_selectedIndex].withOpacity(0.3),
              border: Border.all(
                color: AppColors.tagColors[_selectedIndex],
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.tagColors[_selectedIndex],
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${widget.tagName}',
                  style: TextStyle(
                    color: AppColors.tagColors[_selectedIndex],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedIndex),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
