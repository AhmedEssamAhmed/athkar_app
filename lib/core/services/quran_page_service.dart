import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/hive_service.dart';

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

/// Service that fetches Quran pages directly from Alquran.cloud
/// and caches them in Hive for offline access.
class QuranPageService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _edition = 'quran-uthmani';

  final http.Client _client;
  QuranPageService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch ayahs for a single page (1–604).
  /// Returns cached data if available.
  Future<List<PageAyah>> fetchPage(int pageNumber) async {
    // Try cache first
    final cached = HiveService.loadQuranPage(pageNumber);
    if (cached != null) return cached;

    // Fetch from API
    final url = '$_baseUrl/page/$pageNumber/$_edition';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch page $pageNumber');
    }

    final data = json.decode(response.body);
    if (data['code'] != 200) {
      throw Exception('Quran API error for page $pageNumber');
    }

    final ayahsJson = data['data']['ayahs'] as List;
    final ayahs = ayahsJson.map((a) => PageAyah.fromJson(a)).toList();

    // Cache for offline use
    await HiveService.saveQuranPage(pageNumber, ayahs);

    return ayahs;
  }

  /// Fetch multiple pages in sequence (for pre-loading).
  Future<Map<int, List<PageAyah>>> fetchPages(int start, int end) async {
    final result = <int, List<PageAyah>>{};
    for (int p = start; p <= end; p++) {
      try {
        result[p] = await fetchPage(p);
      } catch (_) {
        // Skip failed pages
      }
    }
    return result;
  }

  void dispose() => _client.close();
}
