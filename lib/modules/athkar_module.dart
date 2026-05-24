/// AthkarModule — Data model and helpers for the Athkar feature.
class Dhikr {
  final String id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final int repeatCount;
  final String? reference;
  final String category;
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

/// Four categories only.
enum AthkarCategory {
  morning('أذكار الصباح', 'Morning Athkar', 'morning'),
  evening('أذكار المساء', 'Evening Athkar', 'evening'),
  sleep('أذكار النوم', 'Sleep Athkar', 'sleep'),
  afterPrayer('أذكار بعد الصلاة', 'After Prayer', 'after_prayer');

  final String arabicTitle;
  final String englishTitle;
  final String key;

  const AthkarCategory(this.arabicTitle, this.englishTitle, this.key);
}

class AthkarData {
  // ─────────────────────────────────────────────────────────────────────────
  // MORNING ATHKAR — أذكار الصباح
  // Time: From dawn until sunrise.
  // ─────────────────────────────────────────────────────────────────────────
  static List<Dhikr> morningAthkar() => [
        Dhikr(
          id: 'morning_01',
          arabicText:
              'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
          transliteration:
              'Allahumma anta rabbi la ilaha illa ant. Khalaqtanee wa ana \'abduk. Wa ana \'ala \'ahdika wa wa\'dika mas-tata\'t. A\'oodhu bika min sharri ma sana\'t. Aboo\'u laka bini\'matika \'alayya, wa aboo\'u laka bidhanbee. Faghfir lee, fa-innahu la yaghfirudh-dhunooba illa ant.',
          translation:
              'O Allah, You are my Lord. There is no god but You. You created me and I am Your servant. I abide by Your covenant and promise as best I can. I seek refuge in You from the evil I have done. I acknowledge Your blessing upon me and I acknowledge my sin. So forgive me, for none forgives sins except You.',
          repeatCount: 1,
          reference: 'Sayyid Al-Istighfar — Bukhari',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_02',
          arabicText:
              'يَا حَيُّ؛ يَا قَيُّومُ؛ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.',
          transliteration:
              'Ya Hayyu ya Qayyum. Birahmatika astagheeth. Aslih lee sha\'nee kullah, wa la takilnee ila nafsee tarfata \'ayn.',
          translation:
              'O Ever-Living, O Sustainer! By Your mercy I call for help. Rectify all my affairs and do not leave me to myself for the blink of an eye.',
          repeatCount: 1,
          reference: 'Al-Hakim — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_03',
          arabicText:
              'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ، وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي، وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي.',
          transliteration:
              'Allahumma innee as\'alukal-\'afiyata fid-dunya wal-akhirah. Allahumma innee as\'alukal-\'afwa wal-\'afiyata fee deenee wa dunyaya, wa ahlee wa malee. Allahummas-tur \'awratee, wa aamin raw\'atee. Allahummah-faznee min bayni yadayya, wa min khalfee, wa \'an yameenee, wa \'an shimalee, wa min fawqee. Wa a\'oodhu bi\'azamatika an ughtala min tahtee.',
          translation:
              'O Allah, I ask You for wellbeing in this world and the hereafter. O Allah, I ask You for pardon and wellbeing in my religion, my worldly affairs, my family and my wealth. O Allah, conceal my faults and calm my fears. O Allah, guard me from in front and behind, from my right and left, and from above. I seek refuge in Your greatness from being struck from below.',
          repeatCount: 1,
          reference: 'Abu Dawud & Ibn Majah — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_04',
          arabicText:
              'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَشَرِّ الشَّيْطَانِ وَشِرْكِهِ.',
          transliteration:
              'Allahumma \'alimal-ghaybi wash-shahadah. Fatiras-samawati wal-ard. Rabba kulli shay\'in wa maleekah. Ash-hadu an la ilaha illa ant. A\'oodhu bika min sharri nafsee, wa sharrish-shaytani wa shirkih.',
          translation:
              'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things. I bear witness that there is no god but You. I seek refuge in You from the evil of my soul and from the evil of Satan and his polytheism.',
          repeatCount: 1,
          reference: 'Abu Dawud & Tirmidhi — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_05',
          arabicText:
              'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا.',
          transliteration:
              'Radheetu billahi rabban, wa bil-islami deenan, wa bi-Muhammadin (ﷺ) nabiyyan.',
          translation:
              'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (ﷺ) as my Prophet.',
          repeatCount: 3,
          reference: 'Abu Dawud, Tirmidhi, Ibn Majah — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_06',
          arabicText:
              'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ.',
          transliteration:
              'Bismillahil-lathee la yadhurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\', wa huwas-samee\'ul-\'aleem.',
          translation:
              'In the name of Allah with Whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, All-Knowing.',
          repeatCount: 3,
          reference: 'Abu Dawud, Tirmidhi, Ibn Majah — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_07',
          arabicText:
              'لَا إِلَهَ إِلَّا اللَّهُ، وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ، وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
          transliteration:
              'La ilaha illallahu, wahdahu la shareeka lah. Lahul-mulku wa lahul-hamd, wa huwa \'ala kulli shay\'in qadeer.',
          translation:
              'There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things powerful.',
          repeatCount: 10,
          reference: 'Muslim',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_08',
          arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.',
          transliteration: 'Subhanallahi wa bihamdih.',
          translation: 'Glory and praise be to Allah.',
          repeatCount: 100,
          reference: 'Bukhari & Muslim',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_09',
          arabicText:
              'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ.',
          transliteration:
              'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namootu, wa ilaykan-nushoor.',
          translation:
              'O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the resurrection.',
          repeatCount: 1,
          reference: 'Tirmidhi — Hasan',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_10',
          arabicText:
              'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ، وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ، وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ، وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ، وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ، وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ، وَعَذَابٍ فِي الْقَبْرِ.',
          transliteration:
              'Asbahna wa asbahal-mulku lillah. Walhamdu lillah. La ilaha illallahu wahdahu la shareeka lah. Lahul-mulku wa lahul-hamd, wa huwa \'ala kulli shay\'in qadeer. Rabbi as\'aluka khayra ma fee hathal-yawmi wa khayra ma ba\'dah. Wa a\'oodhu bika min sharri ma fee hathal-yawmi wa sharri ma ba\'dah. Rabbi a\'oodhu bika minal-kasali wa soo\'il-kibar. Rabbi a\'oodhu bika min \'athabin fin-nari wa \'athabin fil-qabr.',
          translation:
              'We have entered the morning and the whole kingdom belongs to Allah. Praise be to Allah. There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things powerful. O Lord, I ask You for the good of this day and the good of what follows it. I seek refuge in You from the evil of this day and the evil of what follows it. O Lord, I seek refuge in You from laziness and the misery of old age. O Lord, I seek refuge in You from punishment in the Fire and punishment in the grave.',
          repeatCount: 1,
          reference: 'Muslim',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_11',
          arabicText:
              'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ، أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ، وَلَكَ الشُّكْرُ.',
          transliteration:
              'Allahumma ma asbaha bee min ni\'matin, aw bi-ahadin min khalqik. Faminka wahdaka la shareeka lak. Falakal-hamdu wa lakash-shukr.',
          translation:
              'O Allah, whatever blessing I or any of Your creation have entered the morning with, it is from You alone, without partner. So to You belongs all praise and to You belongs all thanks.',
          repeatCount: 1,
          reference: 'Abu Dawud — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_12',
          arabicText:
              'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا، وَمَا كَانَ مِنَ الْمُشْرِكِينَ.',
          transliteration:
              'Asbahna \'ala fitratil-islam, wa \'ala kalimatil-ikhlas, wa \'ala deeni nabiyyina Muhammadin (ﷺ), wa \'ala millati abeena Ibraheema haneefan musliman, wa ma kana minal-mushrikeen.',
          translation:
              'We have entered the morning upon the fitrah of Islam, upon the word of sincerity, upon the religion of our Prophet Muhammad (ﷺ), and upon the way of our father Ibrahim, a true Muslim, and he was not of the polytheists.',
          repeatCount: 1,
          reference: 'Ahmad — Sahih',
          category: 'morning',
        ),
        Dhikr(
          id: 'morning_13',
          arabicText:
              'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ، وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ.',
          transliteration:
              'Allahumma innee asbahtu ushhiduka, wa ushhidu hamalata \'arshik, wa mala\'ikatak, wa jamee\'a khalqik. Annaka antal-lahu la ilaha illa ant, wahdaka la shareeka lak. Wa anna Muhammadan \'abduka wa rasooluk.',
          translation:
              'O Allah, I have entered the morning calling You to witness, and calling to witness the bearers of Your Throne, Your angels, and all of Your creation, that You are Allah, there is no god but You, alone, without partner, and that Muhammad is Your servant and Your Messenger.',
          repeatCount: 4,
          reference: 'Abu Dawud — Sahih',
          category: 'morning',
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // EVENING ATHKAR — أذكار المساء
  // Time: From sunset to the start of Isha time.
  // ─────────────────────────────────────────────────────────────────────────
  static List<Dhikr> eveningAthkar() => [
        Dhikr(
          id: 'evening_01',
          arabicText:
              'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
          transliteration:
              'Allahumma anta rabbi la ilaha illa ant. Khalaqtanee wa ana \'abduk. Wa ana \'ala \'ahdika wa wa\'dika mas-tata\'t. A\'oodhu bika min sharri ma sana\'t. Aboo\'u laka bini\'matika \'alayya, wa aboo\'u laka bidhanbee. Faghfir lee, fa-innahu la yaghfirudh-dhunooba illa ant.',
          translation:
              'O Allah, You are my Lord. There is no god but You. You created me and I am Your servant. I abide by Your covenant and promise as best I can. I seek refuge in You from the evil I have done. I acknowledge Your blessing upon me and I acknowledge my sin. So forgive me, for none forgives sins except You.',
          repeatCount: 1,
          reference: 'Sayyid Al-Istighfar — Bukhari',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_02',
          arabicText:
              'يَا حَيُّ؛ يَا قَيُّومُ؛ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.',
          transliteration:
              'Ya Hayyu ya Qayyum. Birahmatika astagheeth. Aslih lee sha\'nee kullah, wa la takilnee ila nafsee tarfata \'ayn.',
          translation:
              'O Ever-Living, O Sustainer! By Your mercy I call for help. Rectify all my affairs and do not leave me to myself for the blink of an eye.',
          repeatCount: 1,
          reference: 'Al-Hakim — Sahih',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_03',
          arabicText:
              'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ، وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي، وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي.',
          transliteration:
              'Allahumma innee as\'alukal-\'afiyata fid-dunya wal-akhirah. Allahumma innee as\'alukal-\'afwa wal-\'afiyata fee deenee wa dunyaya, wa ahlee wa malee. Allahummas-tur \'awratee, wa aamin raw\'atee. Allahummah-faznee min bayni yadayya, wa min khalfee, wa \'an yameenee, wa \'an shimalee, wa min fawqee. Wa a\'oodhu bi\'azamatika an ughtala min tahtee.',
          translation:
              'O Allah, I ask You for wellbeing in this world and the hereafter. O Allah, I ask You for pardon and wellbeing in my religion, my worldly affairs, my family and my wealth. O Allah, conceal my faults and calm my fears. O Allah, guard me from in front and behind, from my right and left, and from above. I seek refuge in Your greatness from being struck from below.',
          repeatCount: 1,
          reference: 'Abu Dawud & Ibn Majah — Sahih',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_04',
          arabicText:
              'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَشَرِّ الشَّيْطَانِ وَشِرْكِهِ.',
          transliteration:
              'Allahumma \'alimal-ghaybi wash-shahadah. Fatiras-samawati wal-ard. Rabba kulli shay\'in wa maleekah. Ash-hadu an la ilaha illa ant. A\'oodhu bika min sharri nafsee, wa sharrish-shaytani wa shirkih.',
          translation:
              'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things. I bear witness that there is no god but You. I seek refuge in You from the evil of my soul and from the evil of Satan and his polytheism.',
          repeatCount: 1,
          reference: 'Abu Dawud & Tirmidhi — Sahih',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_05',
          arabicText:
              'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا.',
          transliteration:
              'Radheetu billahi rabban, wa bil-islami deenan, wa bi-Muhammadin (ﷺ) nabiyyan.',
          translation:
              'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (ﷺ) as my Prophet.',
          repeatCount: 3,
          reference: 'Abu Dawud, Tirmidhi, Ibn Majah — Sahih',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_06',
          arabicText:
              'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ.',
          transliteration:
              'Bismillahil-lathee la yadhurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\', wa huwas-samee\'ul-\'aleem.',
          translation:
              'In the name of Allah with Whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, All-Knowing.',
          repeatCount: 3,
          reference: 'Abu Dawud, Tirmidhi, Ibn Majah — Sahih',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_07',
          arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.',
          transliteration: 'Subhanallahi wa bihamdih.',
          translation: 'Glory and praise be to Allah.',
          repeatCount: 100,
          reference: 'Bukhari & Muslim',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_08',
          arabicText:
              'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ.',
          transliteration:
              'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namootu, wa ilaykal-maseer.',
          translation:
              'O Allah, by You we enter the evening and by You we enter the morning, by You we live and by You we die, and to You is the final return.',
          repeatCount: 1,
          reference: 'Tirmidhi — Hasan',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_09',
          arabicText:
              'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ، وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ، وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ، وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ، وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ، وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ، وَعَذَابٍ فِي الْقَبْرِ.',
          transliteration:
              'Amsayna wa amsal-mulku lillah. Walhamdu lillah. La ilaha illallahu wahdahu la shareeka lah. Lahul-mulku wa lahul-hamd, wa huwa \'ala kulli shay\'in qadeer. Rabbi as\'aluka khayra ma fee hathihil-laylah wa khayra ma ba\'daha. Wa a\'oodhu bika min sharri ma fee hathihil-laylah wa sharri ma ba\'daha. Rabbi a\'oodhu bika minal-kasali wa soo\'il-kibar. Rabbi a\'oodhu bika min \'athabin fin-nari wa \'athabin fil-qabr.',
          translation:
              'We have entered the evening and the whole kingdom belongs to Allah. Praise be to Allah. There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things powerful. O Lord, I ask You for the good of this night and the good of what follows it. I seek refuge in You from the evil of this night and the evil of what follows it. O Lord, I seek refuge in You from laziness and the misery of old age. O Lord, I seek refuge in You from punishment in the Fire and punishment in the grave.',
          repeatCount: 1,
          reference: 'Muslim',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_10',
          arabicText:
              'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ، أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ، وَلَكَ الشُّكْرُ.',
          transliteration:
              'Allahumma ma amsa bee min ni\'matin, aw bi-ahadin min khalqik. Faminka wahdaka la shareeka lak. Falakal-hamdu wa lakash-shukr.',
          translation:
              'O Allah, whatever blessing I or any of Your creation have entered the evening with, it is from You alone, without partner. So to You belongs all praise and to You belongs all thanks.',
          repeatCount: 1,
          reference: 'Abu Dawud — Sahih',
          category: 'evening',
        ),
        Dhikr(
          id: 'evening_11',
          arabicText:
              'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
          transliteration:
              'A\'oodhu bikalimatillahit-tammati min sharri ma khalaq.',
          translation:
              'I seek refuge in the perfect words of Allah from the evil of what He has created.',
          repeatCount: 3,
          reference: 'Muslim',
          category: 'evening',
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // SLEEP ATHKAR — أذكار النوم
  // ─────────────────────────────────────────────────────────────────────────
  static List<Dhikr> sleepAthkar() => [
        Dhikr(
          id: 'sleep_01',
          arabicText:
              'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.',
          transliteration: 'Bismika Allahumma amootu wa ahya.',
          translation:
              'In Your name, O Allah, I die and I live.',
          repeatCount: 1,
          reference: 'Bukhari',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_02',
          arabicText:
              'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.',
          transliteration:
              'Allahumma qinee \'adhabaka yawma tab\'athu \'ibadak.',
          translation:
              'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
          repeatCount: 3,
          reference: 'Abu Dawud & Tirmidhi — Sahih',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_03',
          arabicText:
              'اللَّهُمَّ بِاسْمِكَ أَحْيَا وَأَمُوتُ.',
          transliteration: 'Allahumma bismika ahya wa amoot.',
          translation: 'O Allah, in Your name I live and I die.',
          repeatCount: 1,
          reference: 'Bukhari & Muslim',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_04',
          arabicText:
              'سُبْحَانَ اللَّهِ.',
          transliteration: 'Subhanallah.',
          translation: 'Glory be to Allah.',
          repeatCount: 33,
          reference: 'Bukhari & Muslim',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_05',
          arabicText: 'الْحَمْدُ لِلَّهِ.',
          transliteration: 'Alhamdulillah.',
          translation: 'All praise be to Allah.',
          repeatCount: 33,
          reference: 'Bukhari & Muslim',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_06',
          arabicText: 'اللَّهُ أَكْبَرُ.',
          transliteration: 'Allahu Akbar.',
          translation: 'Allah is the Greatest.',
          repeatCount: 34,
          reference: 'Bukhari & Muslim',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_07',
          arabicText:
              'اللَّهُمَّ رَبَّ السَّمَاوَاتِ وَرَبَّ الْأَرْضِ، وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ الْأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ، وَأَنْتَ الْآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُونَكَ شَيْءٌ، اقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ.',
          transliteration:
              'Allahumma rabbas-samawati wa rabbal-ard, wa rabbal-\'arshil-\'azeem. Rabbana wa rabba kulli shay\'. Faliqal-habbi wan-nawa, wa munzilat-tawrati wal-injili wal-furqan. A\'oodhu bika min sharri kulli shay\'in anta akhidhun binasiyatih. Allahumma antal-awwalu fa-laysa qablaka shay\', wa antal-akhiru fa-laysa ba\'daka shay\', wa antaz-zahiru fa-laysa fawqaka shay\', wa antal-batinu fa-laysa doonaka shay\'. Iqdi \'annad-dayna wa aghnina minal-faqr.',
          translation:
              'O Allah, Lord of the heavens and Lord of the earth and Lord of the Mighty Throne, our Lord and Lord of all things, Splitter of the grain and the date-stone, Revealer of the Torah, the Gospel, and the Criterion. I seek refuge in You from the evil of all things that You hold by the forelock. O Allah, You are the First and nothing is before You, You are the Last and nothing is after You, You are the Manifest and nothing is above You, You are the Hidden and nothing is beyond You. Settle our debt and spare us from poverty.',
          repeatCount: 1,
          reference: 'Muslim',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_08',
          arabicText:
              'آيَةُ الْكُرْسِيِّ:\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
          transliteration: 'Ayat Al-Kursi — Al-Baqarah 2:255',
          translation:
              'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
          repeatCount: 1,
          reference: 'Bukhari',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_09',
          arabicText:
              'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ.',
          transliteration: 'Surat Al-Ikhlas (112)',
          translation:
              'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
          repeatCount: 3,
          reference: 'Abu Dawud & Tirmidhi — Sahih',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_10',
          arabicText:
              'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ.',
          transliteration: 'Surat Al-Falaq (113)',
          translation:
              'Say: I seek refuge in the Lord of daybreak. From the evil of that which He created. And from the evil of darkness when it settles. And from the evil of the blowers in knots. And from the evil of an envier when he envies.',
          repeatCount: 3,
          reference: 'Abu Dawud & Tirmidhi — Sahih',
          category: 'sleep',
        ),
        Dhikr(
          id: 'sleep_11',
          arabicText:
              'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ.',
          transliteration: 'Surat Al-Nas (114)',
          translation:
              'Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer, who whispers in the breasts of mankind — from among jinn and mankind.',
          repeatCount: 3,
          reference: 'Abu Dawud & Tirmidhi — Sahih',
          category: 'sleep',
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // AFTER PRAYER ATHKAR — أذكار بعد الصلاة
  // ─────────────────────────────────────────────────────────────────────────
  static List<Dhikr> afterPrayerAthkar() => [
        Dhikr(
          id: 'prayer_01',
          arabicText: 'أَسْتَغْفِرُ اللَّهَ.',
          transliteration: 'Astaghfirullah.',
          translation: 'I seek forgiveness from Allah.',
          repeatCount: 3,
          reference: 'Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_02',
          arabicText:
              'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ.',
          transliteration:
              'Allahumma antas-salam wa minkas-salam. Tabarakta ya Thal-jalali wal-ikram.',
          translation:
              'O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of glory and honour.',
          repeatCount: 1,
          reference: 'Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_03',
          arabicText:
              'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ.',
          transliteration:
              'La ilaha illallahu wahdahu la shareeka lah. Lahul-mulku wa lahul-hamd wa huwa \'ala kulli shay\'in qadeer. Allahumma la mani\'a lima a\'tayta, wa la mu\'tiya lima mana\'t, wa la yanfa\'u thal-jaddi minkal-jadd.',
          translation:
              'There is no god but Allah, alone, without partner. His is the dominion and His is the praise and He is over all things powerful. O Allah, none can withhold what You give, and none can give what You withhold, and the wealth of the wealthy does not benefit them against You.',
          repeatCount: 1,
          reference: 'Bukhari & Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_04',
          arabicText: 'سُبْحَانَ اللَّهِ.',
          transliteration: 'Subhanallah.',
          translation: 'Glory be to Allah.',
          repeatCount: 33,
          reference: 'Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_05',
          arabicText: 'الْحَمْدُ لِلَّهِ.',
          transliteration: 'Alhamdulillah.',
          translation: 'All praise be to Allah.',
          repeatCount: 33,
          reference: 'Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_06',
          arabicText: 'اللَّهُ أَكْبَرُ.',
          transliteration: 'Allahu Akbar.',
          translation: 'Allah is the Greatest.',
          repeatCount: 33,
          reference: 'Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_07',
          arabicText:
              'لَا إِلَهَ إِلَّا اللَّهُ، وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ، وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
          transliteration:
              'La ilaha illallahu, wahdahu la shareeka lah. Lahul-mulku wa lahul-hamd, wa huwa \'ala kulli shay\'in qadeer.',
          translation:
              'There is no god but Allah, alone, without partner. His is the dominion and His is the praise, and He is over all things powerful.',
          repeatCount: 1,
          reference: 'Muslim',
          category: 'after_prayer',
        ),
        Dhikr(
          id: 'prayer_08',
          arabicText:
              'آيَةُ الْكُرْسِيِّ:\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
          transliteration: 'Ayat Al-Kursi — Al-Baqarah 2:255',
          translation:
              'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
          repeatCount: 1,
          reference: 'Bukhari — whoever reads it after each prayer, nothing prevents him from entering Paradise except death',
          category: 'after_prayer',
        ),
      ];

  /// Returns all athkar for a given category key.
  static List<Dhikr> forCategory(String key) {
    switch (key) {
      case 'morning':
        return morningAthkar();
      case 'evening':
        return eveningAthkar();
      case 'sleep':
        return sleepAthkar();
      case 'after_prayer':
        return afterPrayerAthkar();
      default:
        return [];
    }
  }
}
