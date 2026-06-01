import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ayah model for Quran reader.
class PageAyah {
  final int number;
  final int numberInSurah;
  final int surahNumber;
  final String surahNameAr;
  final String surahNameEn;
  final String text;
  final int page;
  final int juz;

  const PageAyah({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.surahNameAr,
    required this.surahNameEn,
    required this.text,
    required this.page,
    required this.juz,
  });

  factory PageAyah.fromJson(Map<String, dynamic> json) {
    final surah = json['surah'] as Map<String, dynamic>;
    return PageAyah(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      surahNumber: surah['number'] as int,
      surahNameAr: surah['name'] as String,
      surahNameEn: surah['englishName'] as String,
      text: json['text'] as String,
      page: json['page'] as int,
      juz: json['juz'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'numberInSurah': numberInSurah,
    'surah': {
      'number': surahNumber,
      'name': surahNameAr,
      'englishName': surahNameEn,
    },
    'text': text,
    'page': page,
    'juz': juz,
  };
}

/// Service that manages the Quran pages loaded from the offline asset file.
class QuranPageService {
  static Map<int, List<PageAyah>> _quranCache = {};

  /// Pre-loads all 604 Quran pages from the offline JSON asset file.
  /// This should be called during the application boot sequence (main.dart).
  static Future<void> init() async {
    if (_quranCache.isNotEmpty) return; // Already initialized
    try {
      final String response = await rootBundle.loadString('assets/data/quran.json');
      final Map<String, dynamic> data = json.decode(response);
      _quranCache = data.map((key, value) {
        final pageNum = int.parse(key);
        final list = (value as List).map((e) => PageAyah.fromJson(e as Map<String, dynamic>)).toList();
        return MapEntry(pageNum, list);
      });
    } catch (e) {
      debugPrint('Error loading offline Quran asset: $e');
      _quranCache = {};
    }
  }

  /// Fetch ayahs for a single page (1–604) synchronously from memory.
  Future<List<PageAyah>> fetchPage(int pageNumber) async {
    final page = _quranCache[pageNumber];
    if (page != null) return page;
    throw Exception('Quran page $pageNumber not found in offline database');
  }

  /// Fetch multiple pages in sequence from memory.
  Future<Map<int, List<PageAyah>>> fetchPages(int start, int end) async {
    final result = <int, List<PageAyah>>{};
    for (int p = start; p <= end; p++) {
      final page = _quranCache[p];
      if (page != null) {
        result[p] = page;
      }
    }
    return result;
  }

  void dispose() {
    // No HTTP client to close anymore, but kept to satisfy UI callbacks
  }
}
