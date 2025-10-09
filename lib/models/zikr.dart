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
  
  // Method to get localized default zikrs
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
        meaning: AppLocalizations.of(context)?.zikirAlhamdulillahMeaning ?? 'Hamd Allah\'a mahsustur',
      ),
      Zikr(
        id: 'allahu_akbar',
        name: AppLocalizations.of(context)?.zikirAllahuAkbar ?? 'Allahu Akbar',
        meaning: AppLocalizations.of(context)?.zikirAllahuAkbarMeaning ?? 'Allah en büyüktür',
      ),
      Zikr(
        id: 'la_ilahe_illallah',
        name: AppLocalizations.of(context)?.zikirLaIlaheIllallah ?? 'La ilahe illallah',
        meaning: AppLocalizations.of(context)?.zikirLaIlaheIllallahMeaning ?? 'Allah\'tan başka ilah yoktur',
      ),
      Zikr(
        id: 'estaghfirullah',
        name: AppLocalizations.of(context)?.zikirEstaghfirullah ?? 'Estağfirullah',
        meaning: AppLocalizations.of(context)?.zikirEstaghfirullahMeaning ?? 'Allah\'tan mağfiret dilerim',
      ),
      
      // Pro ile gelen ek zikirler
      Zikr(
        id: 'la_hawle_wala_quwwate',
        name: AppLocalizations.of(context)?.zikirLaHawleWelaKuvvete ?? 'La hawle vela kuvvete',
        meaning: AppLocalizations.of(context)?.zikirLaHawleWelaKuvveteMeaning ?? 'Güç ve kuvvet ancak Allah\'tandır',
      ),
      Zikr(
        id: 'hasbi_allahu',
        name: AppLocalizations.of(context)?.zikirHasbiyallahu ?? 'Hasbiyallahu',
        meaning: AppLocalizations.of(context)?.zikirHasbiyallahuMeaning ?? 'Allah bana yeter, O ne güzel vekildir',
      ),
      Zikr(
        id: 'rabbana_atina',
        name: AppLocalizations.of(context)?.zikirRabbenaAtina ?? 'Rabbena Atina',
        meaning: AppLocalizations.of(context)?.zikirRabbenaAtinaMeaning ?? 'Rabbimiz! Bize dünyada iyilik ver',
      ),
      Zikr(
        id: 'allahume_salli',
        name: AppLocalizations.of(context)?.zikirAllahummeSalli ?? 'Allahumme Salli',
        meaning: AppLocalizations.of(context)?.zikirAllahummeCalliMeaning ?? 'Allah\'ım, Muhammed\'e salat eyle',
      ),
      Zikr(
        id: 'rabbi_zidni_ilmen',
        name: AppLocalizations.of(context)?.zikirRabbiZidniIlmen ?? 'Rabbi Zidni İlmen',
        meaning: AppLocalizations.of(context)?.zikirRabbiZidniIlmenMeaning ?? 'Rabbim! İlmimi artır',
      ),
      Zikr(
        id: 'bismillah',
        name: AppLocalizations.of(context)?.zikirBismillah ?? 'Bismillah',
        meaning: AppLocalizations.of(context)?.zikirBismillahMeaning ?? 'Rahman ve Rahim olan Allah\'ın adıyla',
      ),
      Zikr(
        id: 'innallaha_maal_sabirin',
        name: AppLocalizations.of(context)?.zikirInnallahaMaasSabirin ?? 'İnnallaha maas sabirin',
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
        name: AppLocalizations.of(context)?.zikirMashallah ?? 'Maşallah',
        meaning: AppLocalizations.of(context)?.zikirMashallahMeaning ?? 'Allah\'ın dilediği oldu',
      ),
    ];
  }
  
  static const List<Zikr> defaultZikrs = [
    // Temel zikirler
    Zikr(
      id: 'subhanallah',
      name: 'Subhanallah',
      meaning: 'Allah\'tan münezzeh ve mukaddestir',
    ),
    Zikr(
      id: 'alhamdulillah',
      name: 'Alhamdulillah',
      meaning: 'Hamd Allah\'a mahsustur',
    ),
    Zikr(
      id: 'allahu_akbar',
      name: 'Allahu Akbar',
      meaning: 'Allah en büyüktür',
    ),
    Zikr(
      id: 'la_ilahe_illallah',
      name: 'La ilahe illallah',
      meaning: 'Allah\'tan başka ilah yoktur',
    ),
    Zikr(
      id: 'estaghfirullah',
      name: 'Estağfirullah',
      meaning: 'Allah\'tan mağfiret dilerim',
    ),
    
    // Pro ile gelen ek zikirler
    Zikr(
      id: 'la_hawle_wala_quwwate',
      name: 'La hawle vela kuvvete',
      meaning: 'Güç ve kuvvet ancak Allah\'tandır',
    ),
    Zikr(
      id: 'hasbi_allahu',
      name: 'Hasbiyallahu',
      meaning: 'Allah bana yeter, O ne güzel vekildir',
    ),
    Zikr(
      id: 'rabbana_atina',
      name: 'Rabbena Atina',
      meaning: 'Rabbimiz! Bize dünyada iyilik ver',
    ),
    Zikr(
      id: 'allahume_salli',
      name: 'Allahumme Salli',
      meaning: 'Allah\'ım, Muhammed\'e salat eyle',
    ),
    Zikr(
      id: 'rabbi_zidni_ilmen',
      name: 'Rabbi Zidni İlmen',
      meaning: 'Rabbim! İlmimi artır',
    ),
    Zikr(
      id: 'bismillah',
      name: 'Bismillah',
      meaning: 'Rahman ve Rahim olan Allah\'ın adıyla',
    ),
    Zikr(
      id: 'innallaha_maal_sabirin',
      name: 'İnnallaha maas sabirin',
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
      name: 'Maşallah',
      meaning: 'Allah\'ın dilediği oldu',
    ),
  ];
}