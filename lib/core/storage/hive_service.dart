import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralized Hive storage manager for offline data.
///
/// Box names:
///   • `quran_offline`    – Downloaded Juz data (key = 'juz_1' .. 'juz_30')
///   • `athkar_favorites` – User's favourite Dhikr items
///   • `tasbeeh_history`  – Lifetime counter history
///   • `app_cache`        – General cache (location info, etc.)
class HiveService {
  // ── Box names ──────────────────────────────────────────────────
  static const String quranBox = 'quran_offline';
  static const String favoritesBox = 'athkar_favorites';
  static const String tasbeehBox = 'tasbeeh_history';
  static const String cacheBox = 'app_cache';

  /// Call once at app startup (before runApp).
  static Future<void> init() async {
    await Hive.initFlutter();
    // Open all boxes so they're ready for reads/writes
    await Hive.openBox(quranBox);
    await Hive.openBox(favoritesBox);
    await Hive.openBox(tasbeehBox);
    await Hive.openBox(cacheBox);
  }

  // ═════════════════════════════════════════════════════════════
  // Quran Offline Storage
  // ═════════════════════════════════════════════════════════════

  /// Save a Juz's Ayahs as JSON for offline reading.
  static Future<void> saveJuz(int juzNumber, List<Map<String, dynamic>> ayahs) async {
    final box = Hive.box(quranBox);
    await box.put('juz_$juzNumber', json.encode(ayahs));
  }

  /// Load a previously-downloaded Juz. Returns `null` if not downloaded.
  static List<Map<String, dynamic>>? loadJuz(int juzNumber) {
    final box = Hive.box(quranBox);
    final raw = box.get('juz_$juzNumber');
    if (raw == null) return null;
    final decoded = json.decode(raw as String) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Check if a Juz has been downloaded.
  static bool isJuzDownloaded(int juzNumber) {
    final box = Hive.box(quranBox);
    return box.containsKey('juz_$juzNumber');
  }

  /// Delete a downloaded Juz to free storage.
  static Future<void> deleteJuz(int juzNumber) async {
    final box = Hive.box(quranBox);
    await box.delete('juz_$juzNumber');
  }

  /// Returns a list of Juz numbers that have been downloaded (1–30).
  static List<int> downloadedJuzNumbers() {
    final box = Hive.box(quranBox);
    return box.keys
        .where((k) => k.toString().startsWith('juz_'))
        .map((k) => int.parse(k.toString().replaceFirst('juz_', '')))
        .toList()
      ..sort();
  }

  // ═════════════════════════════════════════════════════════════
  // Athkar Favorites
  // ═════════════════════════════════════════════════════════════

  /// Toggle a Dhikr as favourite. Returns the new state.
  static Future<bool> toggleFavorite(String dhikrId) async {
    final box = Hive.box(favoritesBox);
    final current = box.get(dhikrId, defaultValue: false) as bool;
    await box.put(dhikrId, !current);
    return !current;
  }

  /// Check if a Dhikr is marked as favourite.
  static bool isFavorite(String dhikrId) {
    final box = Hive.box(favoritesBox);
    return box.get(dhikrId, defaultValue: false) as bool;
  }

  /// Get all favourite Dhikr IDs.
  static List<String> allFavoriteIds() {
    final box = Hive.box(favoritesBox);
    return box.keys
        .where((k) => box.get(k) == true)
        .map((k) => k.toString())
        .toList();
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
}
