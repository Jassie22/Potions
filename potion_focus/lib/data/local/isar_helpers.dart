import 'package:isar/isar.dart';

/// Helper extension to get all items from an Isar collection
/// This is a workaround for Isar 3.1.0+1 where findAll() is not available on QueryBuilder
extension IsarCollectionHelpers<T> on IsarCollection<T> {
  /// Get all items from the collection by iterating through IDs
  Future<List<T>> getAllItems() async {
    final count = await this.count();
    if (count == 0) return [];
    
    final items = <T>[];
    // Fetch items by ID range (workaround for missing findAll)
    // Try a reasonable range to cover most cases
    for (int i = 1; i <= (count * 2).clamp(1, 10000); i++) {
      try {
        final item = await get(i);
        if (item != null) {
          items.add(item as T);
          if (items.length >= count) break; // Found all items
        }
      } catch (e) {
        // Skip if ID doesn't exist (gaps in auto-increment)
        continue;
      }
    }
    return items;
  }
  
  /// Get the first item from the collection
  Future<T?> getFirstItem() async {
    final count = await this.count();
    if (count == 0) return null;
    
    // Try to get first few IDs to find the first item
    for (int i = 1; i <= (count + 10).clamp(1, 100); i++) {
      try {
        final item = await get(i);
        if (item != null) {
          return item;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}
