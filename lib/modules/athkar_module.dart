// AthkarModule — Data model and helpers for the Athkar feature.
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Dhikr {
  final String id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final int repeatCount;
  final String? reference;
  final String category;

  Dhikr({
    required this.id,
    required this.arabicText,
    this.transliteration = '',
    this.translation = '',
    this.repeatCount = 1,
    this.reference,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'arabicText': arabicText,
        'transliteration': transliteration,
        'translation': translation,
        'repeatCount': repeatCount,
        'reference': reference,
        'category': category,
      };

  factory Dhikr.fromMap(Map<String, dynamic> map) => Dhikr(
        id: map['id'] as String,
        arabicText: map['arabicText'] as String,
        transliteration: (map['transliteration'] as String?) ?? '',
        translation: (map['translation'] as String?) ?? '',
        repeatCount: (map['repeatCount'] as int?) ?? 1,
        reference: map['reference'] as String?,
        category: map['category'] as String,
      );
}

/// Athkar categories.
enum AthkarCategory {
  morning('أذكار الصباح', 'Morning Athkar', 'morning'),
  evening('أذكار المساء', 'Evening Athkar', 'evening'),
  sleep('أذكار النوم', 'Sleep Athkar', 'sleep'),
  afterPrayer('أذكار بعد الصلاة', 'After Prayer', 'after_prayer'),
  travel('أذكار السفر', 'Travel Athkar', 'travel'),
  home('أذكار المنزل', 'Entering & Leaving Home', 'home'),
  food('أذكار الطعام والشراب', 'Food & Drink', 'food'),
  bathroom('أذكار الخلاء', 'Entering & Leaving Bathroom', 'bathroom'),
  ruqyaSunnah('الرقية من السنة', 'Ruqya from Sunnah', 'ruqya_sunnah'),
  ruqyaQuran('الرقية من القرآن', 'Ruqya from Quran', 'ruqya_quran');

  final String arabicTitle;
  final String englishTitle;
  final String key;

  const AthkarCategory(this.arabicTitle, this.englishTitle, this.key);
}

class AthkarData {
  static List<Dhikr> _allAthkar = [];

  /// Loads and parses all Athkar records from the local JSON asset file.
  /// This should be called during the application boot sequence (main.dart).
  static Future<void> init() async {
    if (_allAthkar.isNotEmpty) return; // Already initialized
    try {
      final String response = await rootBundle.loadString('assets/data/athkar.json');
      final List<dynamic> data = json.decode(response);
      _allAthkar = data.map((json) => Dhikr.fromMap(json)).toList();
    } catch (e) {
      // In development mode, print the loading failure
      debugPrint('Error loading Athkar JSON asset: $e');
      _allAthkar = [];
    }
  }

  /// Returns all athkar for a given category key synchronously from memory.
  static List<Dhikr> forCategory(String key) {
    return _allAthkar.where((dhikr) => dhikr.category == key).toList();
  }
}
