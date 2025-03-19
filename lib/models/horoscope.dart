class Horoscope {
  final String overall;
  final String love;
  final String business;
  final String mood;
  final String color;
  final int luckyNumber;
  final String luckyTime;
  final int lovePercentage;
  final int businessPercentage;
  final int healthPercentage;

  Horoscope({
    required this.overall,
    required this.love,
    required this.business,
    required this.mood,
    required this.color,
    required this.luckyNumber,
    required this.luckyTime,
    required this.lovePercentage,
    required this.businessPercentage,
    required this.healthPercentage,
  });

  factory Horoscope.fromJson(Map<String, dynamic> json) {
    return Horoscope(
      overall: json['overall'] as String,
      love: json['love'] as String,
      business: json['business'] as String,
      mood: json['mood'] as String,
      color: json['color'] as String,
      luckyNumber: json['lucky_number'] as int,
      luckyTime: json['lucky_time'] as String,
      lovePercentage: json['love_percentage'] as int,
      businessPercentage: json['business_percentage'] as int,
      healthPercentage: json['health_percentage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'love': love,
      'business': business,
      'mood': mood,
      'color': color,
      'lucky_number': luckyNumber,
      'lucky_time': luckyTime,
      'love_percentage': lovePercentage,
      'business_percentage': businessPercentage,
      'health_percentage': healthPercentage,
    };
  }
}