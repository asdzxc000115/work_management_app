//근무 모델
class Work {
  final int? id;
  final int workplaceId;
  final DateTime date;
  final String payType; // '시급', '일급', '월급' 등
  final double hourlyWage;
  final DateTime startTime;
  final DateTime endTime;
  final int breakMinutes; // 휴게시간 (분)
  final double extraPay; // 추가수당
  final String? extraPayNote; // 추가수당 메모

  Work({
    this.id,
    required this.workplaceId,
    required this.date,
    required this.payType,
    required this.hourlyWage,
    required this.startTime,
    required this.endTime,
    this.breakMinutes = 0,
    this.extraPay = 0,
    this.extraPayNote,
  });

  // 근무시간 계산 (휴게시간 제외)
  double get workHours {
    final totalMinutes = endTime.difference(startTime).inMinutes;
    final actualMinutes = totalMinutes - breakMinutes;
    return actualMinutes / 60.0;
  }

  // 급여 계산
  double get totalPay {
    if (payType == '시급') {
      return (workHours * hourlyWage) + extraPay;
    }
    // 일급이나 월급의 경우 별도 계산 로직 필요
    return hourlyWage + extraPay;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workplace_id': workplaceId,
      'date': date.toIso8601String(),
      'pay_type': payType,
      'hourly_wage': hourlyWage,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'break_minutes': breakMinutes,
      'extra_pay': extraPay,
      'extra_pay_note': extraPayNote,
    };
  }

  factory Work.fromMap(Map<String, dynamic> map) {
    return Work(
      id: map['id'],
      workplaceId: map['workplace_id'],
      date: DateTime.parse(map['date']),
      payType: map['pay_type'],
      hourlyWage: map['hourly_wage'].toDouble(),
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      breakMinutes: map['break_minutes'],
      extraPay: map['extra_pay'].toDouble(),
      extraPayNote: map['extra_pay_note'],
    );
  }

  // API 연동시 필요
  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'],
      workplaceId: json['workplace_id'],
      date: DateTime.parse(json['date']),
      payType: json['pay_type'],
      hourlyWage: json['hourly_wage'].toDouble(),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      breakMinutes: json['break_minutes'] ?? 0,
      extraPay: (json['extra_pay'] ?? 0).toDouble(),
      extraPayNote: json['extra_pay_note'],
    );
  }
}