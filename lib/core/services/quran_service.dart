import 'api_client.dart';

/// Data class for a single Quran Ayah returned by the backend.
class QuranAyah {
  final int number;
  final int numberInSurah;
  final int surahNumber;
  final String surahNameAr;
  final String surahNameEn;
  final String textAr;
  final int page;
  final int juz;

  const QuranAyah({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.surahNameAr,
    required this.surahNameEn,
    required this.textAr,
    required this.page,
    required this.juz,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) => QuranAyah(
        number: json['number'] as int,
        numberInSurah: json['number_in_surah'] as int,
        surahNumber: json['surah_number'] as int,
        surahNameAr: json['surah_name_ar'] as String,
        surahNameEn: json['surah_name_en'] as String,
        textAr: json['text_ar'] as String,
        page: json['page'] as int,
        juz: json['juz'] as int,
      );

  /// Convert to JSON map for Hive offline storage.
  Map<String, dynamic> toJson() => {
        'number': number,
        'number_in_surah': numberInSurah,
        'surah_number': surahNumber,
        'surah_name_ar': surahNameAr,
        'surah_name_en': surahNameEn,
        'text_ar': textAr,
        'page': page,
        'juz': juz,
      };
}

/// Communicates with the FastAPI `/api/quran/juz/{number}` endpoint.
class QuranService {
  final ApiClient _api;

  QuranService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Fetch all Ayahs for [juzNumber] (1–30) from the backend.
  Future<List<QuranAyah>> fetchJuz(int juzNumber) async {
    final data = await _api.get('/api/quran/juz/$juzNumber');
    return (data as List).map((e) => QuranAyah.fromJson(e)).toList();
  }
}
