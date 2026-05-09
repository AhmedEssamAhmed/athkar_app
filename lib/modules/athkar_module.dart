/// AthkarModule — Data model and helpers for the Athkar feature.
///
/// This module manages the Athkar categories, individual dhikr items,
/// and their repetition counts.
class Dhikr {
  final String id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final int repeatCount;
  final String? reference; // e.g. "Sahih Muslim 2723"
  final String category; // e.g. "morning", "evening", "sleep"
  bool isFavorite;

  Dhikr({
    required this.id,
    required this.arabicText,
    this.transliteration = '',
    this.translation = '',
    this.repeatCount = 1,
    this.reference,
    required this.category,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'arabicText': arabicText,
        'transliteration': transliteration,
        'translation': translation,
        'repeatCount': repeatCount,
        'reference': reference,
        'category': category,
        'isFavorite': isFavorite,
      };

  factory Dhikr.fromMap(Map<String, dynamic> map) => Dhikr(
        id: map['id'] as String,
        arabicText: map['arabicText'] as String,
        transliteration: (map['transliteration'] as String?) ?? '',
        translation: (map['translation'] as String?) ?? '',
        repeatCount: (map['repeatCount'] as int?) ?? 1,
        reference: map['reference'] as String?,
        category: map['category'] as String,
        isFavorite: (map['isFavorite'] as bool?) ?? false,
      );
}

/// Predefined categories matching the Stitch "Athkar Categories" screen.
enum AthkarCategory {
  morning('أذكار الصباح', 'Morning Athkar', 'morning'),
  evening('أذكار المساء', 'Evening Athkar', 'evening'),
  afterPrayer('أذكار بعد الصلاة', 'After Prayer', 'after_prayer'),
  sleep('أذكار النوم', 'Sleep Athkar', 'sleep'),
  wakeUp('أذكار الاستيقاظ', 'Wake-up Athkar', 'wake_up'),
  quranDua('أدعية قرآنية', 'Quranic Duas', 'quran_dua'),
  propheticDua('أدعية نبوية', 'Prophetic Duas', 'prophetic_dua'),
  misc('أذكار متنوعة', 'Miscellaneous', 'misc');

  final String arabicTitle;
  final String englishTitle;
  final String key;

  const AthkarCategory(this.arabicTitle, this.englishTitle, this.key);
}

/// Sample data – in production, this is loaded from Hive / SQLite.
class AthkarData {
  static List<Dhikr> sampleMorningAthkar() => [
        Dhikr(
          id: 'morning_01',
          arabicText: 'أَصْبَحْنَا وَأَصْبَحَ المُلْكُ لِلَّهِ، وَالحَمْدُ لِلَّهِ',
          transliteration: 'Asbahna wa asbahal mulku lillah, walhamdu lillah',
          translation: 'We have entered the morning and the kingdom belongs to Allah, and all praise is for Allah.',
          repeatCount: 1,
          reference: 'Muslim',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_02',
          arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
          transliteration: 'Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namutu wa ilaykan nushur',
          translation: 'O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the resurrection.',
          repeatCount: 1,
          reference: 'Tirmidhi',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_03',
          arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
          transliteration: 'SubhanAllahi wa bihamdihi',
          translation: 'Glory and praise be to Allah.',
          repeatCount: 100,
          reference: 'Bukhari & Muslim',
          category: 'morning',
        ),
      ];
}
