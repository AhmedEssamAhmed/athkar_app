/// Complete Quran metadata — all 114 surahs and 30 juz.
class SurahInfo {
  final int number;
  final String nameAr;
  final String nameEn;
  final int verses;
  final bool isMeccan;
  final int startPage;
  const SurahInfo(this.number, this.nameAr, this.nameEn, this.verses, this.isMeccan, this.startPage);
  String get type => isMeccan ? 'Meccan' : 'Medinan';
  String get typeAr => isMeccan ? 'مكية' : 'مدنية';
}

class JuzInfo {
  final int number;
  final String nameAr;
  final int startSurah;
  final int startAyah;
  final int startPage;
  const JuzInfo(this.number, this.nameAr, this.startSurah, this.startAyah, this.startPage);
}

class QuranMeta {
  static const int totalPages = 604;

  static const List<SurahInfo> surahs = [
    SurahInfo(1,'الفاتحة','Al-Fatiha',7,true,1),
    SurahInfo(2,'البقرة','Al-Baqarah',286,false,2),
    SurahInfo(3,'آل عمران','Ali Imran',200,false,50),
    SurahInfo(4,'النساء','An-Nisa',176,false,77),
    SurahInfo(5,'المائدة','Al-Ma\'idah',120,false,106),
    SurahInfo(6,'الأنعام','Al-An\'am',165,true,128),
    SurahInfo(7,'الأعراف','Al-A\'raf',206,true,151),
    SurahInfo(8,'الأنفال','Al-Anfal',75,false,177),
    SurahInfo(9,'التوبة','At-Tawbah',129,false,187),
    SurahInfo(10,'يونس','Yunus',109,true,208),
    SurahInfo(11,'هود','Hud',123,true,221),
    SurahInfo(12,'يوسف','Yusuf',111,true,235),
    SurahInfo(13,'الرعد','Ar-Ra\'d',43,false,249),
    SurahInfo(14,'إبراهيم','Ibrahim',52,true,255),
    SurahInfo(15,'الحجر','Al-Hijr',99,true,262),
    SurahInfo(16,'النحل','An-Nahl',128,true,267),
    SurahInfo(17,'الإسراء','Al-Isra',111,true,282),
    SurahInfo(18,'الكهف','Al-Kahf',110,true,293),
    SurahInfo(19,'مريم','Maryam',98,true,305),
    SurahInfo(20,'طه','Taha',135,true,312),
    SurahInfo(21,'الأنبياء','Al-Anbiya',112,true,322),
    SurahInfo(22,'الحج','Al-Hajj',78,false,332),
    SurahInfo(23,'المؤمنون','Al-Mu\'minun',118,true,342),
    SurahInfo(24,'النور','An-Nur',64,false,350),
    SurahInfo(25,'الفرقان','Al-Furqan',77,true,359),
    SurahInfo(26,'الشعراء','Ash-Shu\'ara',227,true,367),
    SurahInfo(27,'النمل','An-Naml',93,true,377),
    SurahInfo(28,'القصص','Al-Qasas',88,true,385),
    SurahInfo(29,'العنكبوت','Al-Ankabut',69,true,396),
    SurahInfo(30,'الروم','Ar-Rum',60,true,404),
    SurahInfo(31,'لقمان','Luqman',34,true,411),
    SurahInfo(32,'السجدة','As-Sajdah',30,true,415),
    SurahInfo(33,'الأحزاب','Al-Ahzab',73,false,418),
    SurahInfo(34,'سبأ','Saba',54,true,428),
    SurahInfo(35,'فاطر','Fatir',45,true,434),
    SurahInfo(36,'يس','Ya-Sin',83,true,440),
    SurahInfo(37,'الصافات','As-Saffat',182,true,446),
    SurahInfo(38,'ص','Sad',88,true,453),
    SurahInfo(39,'الزمر','Az-Zumar',75,true,458),
    SurahInfo(40,'غافر','Ghafir',85,true,467),
    SurahInfo(41,'فصلت','Fussilat',54,true,477),
    SurahInfo(42,'الشورى','Ash-Shura',53,true,483),
    SurahInfo(43,'الزخرف','Az-Zukhruf',89,true,489),
    SurahInfo(44,'الدخان','Ad-Dukhan',59,true,496),
    SurahInfo(45,'الجاثية','Al-Jathiyah',37,true,499),
    SurahInfo(46,'الأحقاف','Al-Ahqaf',35,true,502),
    SurahInfo(47,'محمد','Muhammad',38,false,507),
    SurahInfo(48,'الفتح','Al-Fath',29,false,511),
    SurahInfo(49,'الحجرات','Al-Hujurat',18,false,515),
    SurahInfo(50,'ق','Qaf',45,true,518),
    SurahInfo(51,'الذاريات','Adh-Dhariyat',60,true,520),
    SurahInfo(52,'الطور','At-Tur',49,true,523),
    SurahInfo(53,'النجم','An-Najm',62,true,526),
    SurahInfo(54,'القمر','Al-Qamar',55,true,528),
    SurahInfo(55,'الرحمن','Ar-Rahman',78,false,531),
    SurahInfo(56,'الواقعة','Al-Waqi\'ah',96,true,534),
    SurahInfo(57,'الحديد','Al-Hadid',29,false,537),
    SurahInfo(58,'المجادلة','Al-Mujadila',22,false,542),
    SurahInfo(59,'الحشر','Al-Hashr',24,false,545),
    SurahInfo(60,'الممتحنة','Al-Mumtahanah',13,false,549),
    SurahInfo(61,'الصف','As-Saff',14,false,551),
    SurahInfo(62,'الجمعة','Al-Jumu\'ah',11,false,553),
    SurahInfo(63,'المنافقون','Al-Munafiqun',11,false,554),
    SurahInfo(64,'التغابن','At-Taghabun',18,false,556),
    SurahInfo(65,'الطلاق','At-Talaq',12,false,558),
    SurahInfo(66,'التحريم','At-Tahrim',12,false,560),
    SurahInfo(67,'الملك','Al-Mulk',30,true,562),
    SurahInfo(68,'القلم','Al-Qalam',52,true,564),
    SurahInfo(69,'الحاقة','Al-Haqqah',52,true,566),
    SurahInfo(70,'المعارج','Al-Ma\'arij',44,true,568),
    SurahInfo(71,'نوح','Nuh',28,true,570),
    SurahInfo(72,'الجن','Al-Jinn',28,true,572),
    SurahInfo(73,'المزمل','Al-Muzzammil',20,true,574),
    SurahInfo(74,'المدثر','Al-Muddaththir',56,true,575),
    SurahInfo(75,'القيامة','Al-Qiyamah',40,true,577),
    SurahInfo(76,'الإنسان','Al-Insan',31,false,578),
    SurahInfo(77,'المرسلات','Al-Mursalat',50,true,580),
    SurahInfo(78,'النبأ','An-Naba',40,true,582),
    SurahInfo(79,'النازعات','An-Nazi\'at',46,true,583),
    SurahInfo(80,'عبس','Abasa',42,true,585),
    SurahInfo(81,'التكوير','At-Takwir',29,true,586),
    SurahInfo(82,'الانفطار','Al-Infitar',19,true,587),
    SurahInfo(83,'المطففين','Al-Mutaffifin',36,true,587),
    SurahInfo(84,'الانشقاق','Al-Inshiqaq',25,true,589),
    SurahInfo(85,'البروج','Al-Buruj',22,true,590),
    SurahInfo(86,'الطارق','At-Tariq',17,true,591),
    SurahInfo(87,'الأعلى','Al-A\'la',19,true,591),
    SurahInfo(88,'الغاشية','Al-Ghashiyah',26,true,592),
    SurahInfo(89,'الفجر','Al-Fajr',30,true,593),
    SurahInfo(90,'البلد','Al-Balad',20,true,594),
    SurahInfo(91,'الشمس','Ash-Shams',15,true,595),
    SurahInfo(92,'الليل','Al-Layl',21,true,595),
    SurahInfo(93,'الضحى','Ad-Duha',11,true,596),
    SurahInfo(94,'الشرح','Ash-Sharh',8,true,596),
    SurahInfo(95,'التين','At-Tin',8,true,597),
    SurahInfo(96,'العلق','Al-Alaq',19,true,597),
    SurahInfo(97,'القدر','Al-Qadr',5,true,598),
    SurahInfo(98,'البينة','Al-Bayyinah',8,false,598),
    SurahInfo(99,'الزلزلة','Az-Zalzalah',8,false,599),
    SurahInfo(100,'العاديات','Al-Adiyat',11,true,599),
    SurahInfo(101,'القارعة','Al-Qari\'ah',11,true,600),
    SurahInfo(102,'التكاثر','At-Takathur',8,true,600),
    SurahInfo(103,'العصر','Al-Asr',3,true,601),
    SurahInfo(104,'الهمزة','Al-Humazah',9,true,601),
    SurahInfo(105,'الفيل','Al-Fil',5,true,601),
    SurahInfo(106,'قريش','Quraysh',4,true,602),
    SurahInfo(107,'الماعون','Al-Ma\'un',7,true,602),
    SurahInfo(108,'الكوثر','Al-Kawthar',3,true,602),
    SurahInfo(109,'الكافرون','Al-Kafirun',6,true,603),
    SurahInfo(110,'النصر','An-Nasr',3,false,603),
    SurahInfo(111,'المسد','Al-Masad',5,true,603),
    SurahInfo(112,'الإخلاص','Al-Ikhlas',4,true,604),
    SurahInfo(113,'الفلق','Al-Falaq',5,true,604),
    SurahInfo(114,'الناس','An-Nas',6,true,604),
  ];

  static const List<JuzInfo> juzList = [
    JuzInfo(1,'الم',1,1,1),
    JuzInfo(2,'سيقول',2,142,22),
    JuzInfo(3,'تلك الرسل',2,253,42),
    JuzInfo(4,'لن تنالوا',3,92,62),
    JuzInfo(5,'والمحصنات',4,24,82),
    JuzInfo(6,'لا يحب الله',4,148,102),
    JuzInfo(7,'وإذا سمعوا',5,83,121),
    JuzInfo(8,'ولو أننا',6,111,142),
    JuzInfo(9,'قال الملأ',7,88,162),
    JuzInfo(10,'واعلموا',8,41,182),
    JuzInfo(11,'يعتذرون',9,93,201),
    JuzInfo(12,'وما من دابة',11,6,222),
    JuzInfo(13,'وما أبرئ',12,53,242),
    JuzInfo(14,'ربما',15,1,262),
    JuzInfo(15,'سبحان الذي',17,1,282),
    JuzInfo(16,'قال ألم',18,75,302),
    JuzInfo(17,'اقترب للناس',21,1,322),
    JuzInfo(18,'قد أفلح',23,1,342),
    JuzInfo(19,'وقال الذين',25,21,362),
    JuzInfo(20,'أمن خلق',27,56,382),
    JuzInfo(21,'اتل ما أوحي',29,46,402),
    JuzInfo(22,'ومن يقنت',33,31,422),
    JuzInfo(23,'وما لي',36,28,442),
    JuzInfo(24,'فمن أظلم',39,32,462),
    JuzInfo(25,'إليه يرد',41,47,482),
    JuzInfo(26,'حم',46,1,502),
    JuzInfo(27,'قال فما خطبكم',51,31,522),
    JuzInfo(28,'قد سمع الله',58,1,542),
    JuzInfo(29,'تبارك',67,1,562),
    JuzInfo(30,'عم',78,1,582),
  ];

  /// Get the surah info by 1-based number.
  static SurahInfo getSurah(int number) => surahs[number - 1];

  /// Get the juz info by 1-based number.
  static JuzInfo getJuz(int number) => juzList[number - 1];

  /// Find which surah a page belongs to (returns the last surah that starts on or before this page).
  static SurahInfo surahForPage(int page) {
    SurahInfo result = surahs.first;
    for (final s in surahs) {
      if (s.startPage <= page) result = s;
      else break;
    }
    return result;
  }

  /// Find which juz a page belongs to.
  static JuzInfo juzForPage(int page) {
    JuzInfo result = juzList.first;
    for (final j in juzList) {
      if (j.startPage <= page) result = j;
      else break;
    }
    return result;
  }
}
