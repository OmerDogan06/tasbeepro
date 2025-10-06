class CounterData {
  final String zikrId;
  final int count;
  final int target;
  final DateTime lastUpdated;
  
  CounterData({
    required this.zikrId,
    required this.count,
    required this.target,
    required this.lastUpdated,
  });
  
  factory CounterData.fromJson(Map<String, dynamic> json) {
    return CounterData(
      zikrId: json['zikrId'],
      count: json['count'],
      target: json['target'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'zikrId': zikrId,
      'count': count,
      'target': target,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  CounterData copyWith({
    String? zikrId,
    int? count,
    int? target,
    DateTime? lastUpdated,
  }) {
    return CounterData(
      zikrId: zikrId ?? this.zikrId,
      count: count ?? this.count,
      target: target ?? this.target,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}