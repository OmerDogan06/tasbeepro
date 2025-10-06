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