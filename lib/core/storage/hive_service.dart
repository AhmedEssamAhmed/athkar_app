import 'package:hive_flutter/hive_flutter.dart';

/// Centralized Hive storage manager for offline data.
///
/// Box names:
///   • `tasbeeh_history`  – Lifetime counter history
///   • `app_cache`        – General cache (location info, etc.)
///   • `athkar_progress`  – Daily prayer count progress
class HiveService {
  // ── Box names ──────────────────────────────────────────────────
  static const String tasbeehBox = 'tasbeeh_history';
  static const String cacheBox = 'app_cache';
  static const String athkarProgressBox = 'athkar_progress';

  /// Call once at app startup (before runApp).
  static Future<void> init() async {
    await Hive.initFlutter();
    // Open all boxes so they're ready for reads/writes
    await Hive.openBox(tasbeehBox);
    await Hive.openBox(cacheBox);
    await Hive.openBox(athkarProgressBox);
  }

  // ═════════════════════════════════════════════════════════════
  // Tasbeeh History
  // ═════════════════════════════════════════════════════════════

  /// Save a tasbeeh session result.
  static Future<void> saveTasbeehSession({
    required String dhikrName,
    required int count,
    required int target,
  }) async {
    final box = Hive.box(tasbeehBox);
    final sessions = (box.get('sessions', defaultValue: []) as List).cast<Map>();
    sessions.add({
      'dhikr': dhikrName,
      'count': count,
      'target': target,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await box.put('sessions', sessions);

    // Update lifetime total
    final lifetime = box.get('lifetime_total', defaultValue: 0) as int;
    await box.put('lifetime_total', lifetime + count);
  }

  /// Get the lifetime total count across all sessions.
  static int lifetimeTotal() {
    final box = Hive.box(tasbeehBox);
    return box.get('lifetime_total', defaultValue: 0) as int;
  }

  // ═════════════════════════════════════════════════════════════
  // General Cache
  // ═════════════════════════════════════════════════════════════

  /// Cache any key-value pair (e.g., last known location).
  static Future<void> cacheValue(String key, dynamic value) async {
    final box = Hive.box(cacheBox);
    await box.put(key, value);
  }

  /// Read a cached value.
  static dynamic getCachedValue(String key) {
    final box = Hive.box(cacheBox);
    return box.get(key);
  }

  // ═════════════════════════════════════════════════════════════
  // Athkar Progress
  // ═════════════════════════════════════════════════════════════

  static Future<void> saveDhikrProgress(String id, int remaining) async {
    final box = Hive.box(athkarProgressBox);
    await box.put(id, remaining);
  }

  static int? getDhikrProgress(String id) {
    final box = Hive.box(athkarProgressBox);
    return box.get(id) as int?;
  }

  static Future<void> resetCategoryProgress(List<String> ids) async {
    final box = Hive.box(athkarProgressBox);
    await box.deleteAll(ids);
  }
}
