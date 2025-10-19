import 'package:get/get.dart';
import '../l10n/app_localizations.dart';

class Zikr {
  final String id;
  final String name;
  final String? meaning;
  final bool isCustom;
  
  const Zikr({
    required this.id,
    required this.name,
    this.meaning,
    this.isCustom = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'meaning': meaning,
      'isCustom': isCustom,
    };
  }
  
  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      id: json['id'],
      name: json['name'],
      meaning: json['meaning'],
      isCustom: json['isCustom'] ?? false,
    );
  }
  
  // Global mobil uygulama için optimize edilmiş lokalize zikirler
  static List<Zikr> getLocalizedDefaultZikrs() {
    final context = Get.context;
    if (context == null) return defaultZikrs;
    
    return [
      // Temel zikirler
      Zikr(
        id: 'subhanallah',
        name: AppLocalizations.of(context)?.zikirSubhanallah ?? 'Subhanallah',
        meaning: AppLocalizations.of(context)?.zikirSubhanallahMeaning ?? 'Allah\'tan münezzeh ve mukaddestir',
      ),
      Zikr(
        id: 'alhamdulillah',
        name: AppLocalizations.of(context)?.zikirAlhamdulillah ?? 'Alhamdulillah',
        meaning: AppLocalizations.of(context)?.zikirAlhamdulillahMeaning ?? 'Bütün övgüler yalnızca Allah’adır',
      ),
      Zikr(
        id: 'allahu_akbar',
        name: AppLocalizations.of(context)?.zikirAllahuAkbar ?? 'Allahu Akbar',
        meaning: AppLocalizations.of(context)?.zikirAllahuAkbarMeaning ?? 'Allah en büyüktür',
      ),
      Zikr(
        id: 'la_ilaha_illallah',
        name: AppLocalizations.of(context)?.zikirLaIlaheIllallah ?? 'La ilaha illAllah',
        meaning: AppLocalizations.of(context)?.zikirLaIlaheIllallahMeaning ?? 'Allah’tan başka ilah yoktur',
      ),
      Zikr(
        id: 'estaghfirullah',
        name: AppLocalizations.of(context)?.zikirEstaghfirullah ?? 'Astaghfirullah',
        meaning: AppLocalizations.of(context)?.zikirEstaghfirullahMeaning ?? 'Allah’tan mağfiret dilerim',
      ),
      
      // Pro ile gelen ek zikirler
      Zikr(
        id: 'la_hawle_wala_quwwate',
        name: AppLocalizations.of(context)?.zikirLaHawleWelaKuvvete ?? 'La hawla wa la quwwata illa billah',
        meaning: AppLocalizations.of(context)?.zikirLaHawleWelaKuvveteMeaning ?? 'Güç ve kuvvet ancak Allah’tandır',
      ),
      Zikr(
        id: 'hasbi_allahu',
        name: AppLocalizations.of(context)?.zikirHasbiyallahu ?? 'HasbiyAllahu wa ni’mal wakeel',
        meaning: AppLocalizations.of(context)?.zikirHasbiyallahuMeaning ?? 'Allah bana yeter, O ne güzel vekildir',
      ),
      Zikr(
        id: 'rabbana_atina',
        name: AppLocalizations.of(context)?.zikirRabbenaAtina ?? 'Rabbana Atina',
        meaning: AppLocalizations.of(context)?.zikirRabbenaAtinaMeaning ?? 'Rabbimiz! Bize dünyada iyilik ver',
      ),
      Zikr(
        id: 'allahume_salli',
        name: AppLocalizations.of(context)?.zikirAllahummeSalli ?? 'Allahumma Salli',
        meaning: AppLocalizations.of(context)?.zikirAllahummeCalliMeaning ?? 'Allahım, Muhammed’e salat eyle',
      ),
      Zikr(
        id: 'rabbi_zidni_ilmen',
        name: AppLocalizations.of(context)?.zikirRabbiZidniIlmen ?? 'Rabbi Zidni Ilm',
        meaning: AppLocalizations.of(context)?.zikirRabbiZidniIlmenMeaning ?? 'Rabbim! İlmimi artır',
      ),
      Zikr(
        id: 'bismillah',
        name: AppLocalizations.of(context)?.zikirBismillah ?? 'Bismillah',
        meaning: AppLocalizations.of(context)?.zikirBismillahMeaning ?? 'Rahman ve Rahim olan Allah’ın adıyla',
      ),
      Zikr(
        id: 'innallaha_maas_sabirin',
        name: AppLocalizations.of(context)?.zikirInnallahaMaasSabirin ?? 'Innalaha ma’as sabirin',
        meaning: AppLocalizations.of(context)?.zikirInnallahaMaasSabirinMeaning ?? 'Şüphesiz Allah sabredenlerle beraberdir',
      ),
      Zikr(
        id: 'allahu_latif',
        name: AppLocalizations.of(context)?.zikirAllahuLatif ?? 'Allahu Latif',
        meaning: AppLocalizations.of(context)?.zikirAllahuLatifMeaning ?? 'Allah kullarına karşı çok merhametlidir',
      ),
      Zikr(
        id: 'ya_rahman',
        name: AppLocalizations.of(context)?.zikirYaRahman ?? 'Ya Rahman Ya Rahim',
        meaning: AppLocalizations.of(context)?.zikirYaRahmanMeaning ?? 'Ey Rahman, Ey Rahim',
      ),
      Zikr(
        id: 'tabarak_allah',
        name: AppLocalizations.of(context)?.zikirTabarakAllah ?? 'Tabarak Allah',
        meaning: AppLocalizations.of(context)?.zikirTabarakAllahMeaning ?? 'Allah mübarektir',
      ),
      Zikr(
        id: 'mashallah',
        name: AppLocalizations.of(context)?.zikirMashallah ?? 'MashaAllah',
        meaning: AppLocalizations.of(context)?.zikirMashallahMeaning ?? 'Allah’ın dilediği oldu',
      ),
    ];
  }

  // Default list (fallback)
  static const List<Zikr> defaultZikrs = [
    Zikr(
      id: 'subhanallah',
      name: 'Subhanallah',
      meaning: 'Allah’tan münezzeh ve mukaddestir',
    ),
    Zikr(
      id: 'alhamdulillah',
      name: 'Alhamdulillah',
      meaning: 'Bütün övgüler yalnızca Allah’adır',
    ),
    Zikr(
      id: 'allahu_akbar',
      name: 'Allahu Akbar',
      meaning: 'Allah en büyüktür',
    ),
    Zikr(
      id: 'la_ilaha_illallah',
      name: 'La ilaha illAllah',
      meaning: 'Allah’tan başka ilah yoktur',
    ),
    Zikr(
      id: 'estaghfirullah',
      name: 'Astaghfirullah',
      meaning: 'Allah’tan mağfiret dilerim',
    ),
    Zikr(
      id: 'la_hawle_wala_quwwate',
      name: 'La hawla wa la quwwata illa billah',
      meaning: 'Güç ve kuvvet ancak Allah’tandır',
    ),
    Zikr(
      id: 'hasbi_allahu',
      name: 'HasbiyAllahu wa ni’mal wakeel',
      meaning: 'Allah bana yeter, O ne güzel vekildir',
    ),
    Zikr(
      id: 'rabbana_atina',
      name: 'Rabbana Atina',
      meaning: 'Rabbimiz! Bize dünyada iyilik ver',
    ),
    Zikr(
      id: 'allahume_salli',
      name: 'Allahumma Salli',
      meaning: 'Allahım, Muhammed’e salat eyle',
    ),
    Zikr(
      id: 'rabbi_zidni_ilmen',
      name: 'Rabbi Zidni Ilm',
      meaning: 'Rabbim! İlmimi artır',
    ),
    Zikr(
      id: 'bismillah',
      name: 'Bismillah',
      meaning: 'Rahman ve Rahim olan Allah’ın adıyla',
    ),
    Zikr(
      id: 'innallaha_maas_sabirin',
      name: 'Innalaha ma’as sabirin',
      meaning: 'Şüphesiz Allah sabredenlerle beraberdir',
    ),
    Zikr(
      id: 'allahu_latif',
      name: 'Allahu Latif',
      meaning: 'Allah kullarına karşı çok merhametlidir',
    ),
    Zikr(
      id: 'ya_rahman',
      name: 'Ya Rahman Ya Rahim',
      meaning: 'Ey Rahman, Ey Rahim',
    ),
    Zikr(
      id: 'tabarak_allah',
      name: 'Tabarak Allah',
      meaning: 'Allah mübarektir',
    ),
    Zikr(
      id: 'mashallah',
      name: 'MashaAllah',
      meaning: 'Allah’ın dilediği oldu',
    ),
  ];
}
