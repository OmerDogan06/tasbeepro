class WidgetZikrRecord {
  final String id;
  final String zikrId;
  final String zikrName;
  final int count;
  final DateTime date;

  WidgetZikrRecord({
    required this.id,
    required this.zikrId,
    required this.zikrName,
    required this.count,
    required this.date,
  });

  // Android'den gelen veriler için fromJson (timestamp long olarak gelir)
  factory WidgetZikrRecord.fromJson(Map<String, dynamic> json) {
    return WidgetZikrRecord(
      id: json['id'].toString(),
      zikrId: json['zikrId'] ?? json['zikr_id'] ?? '',
      zikrName: json['zikrName'] ?? json['zikr_name'] ?? '',
      count: json['count'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  // Flutter SharedPreferences için toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zikrId': zikrId,
      'zikrName': zikrName,
      'count': count,
      'timestamp': date.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'WidgetZikrRecord(id: $id, zikrId: $zikrId, zikrName: $zikrName, count: $count, date: $date)';
  }
}