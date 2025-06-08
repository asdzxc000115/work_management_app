//근무지 모델
import 'package:flutter/material.dart';

class Workplace {
  final int? id;
  final String name;
  final int payday; // 월급일 (1-31)
  final Color color;
  final bool deductTax; // 세금 공제 여부
  final bool deductInsurance; // 4대보험 공제 여부
  final bool isActive;

  Workplace({
    this.id,
    required this.name,
    required this.payday,
    required this.color,
    this.deductTax = false,
    this.deductInsurance = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'payday': payday,
      'color': color.value,
      'deduct_tax': deductTax ? 1 : 0,
      'deduct_insurance': deductInsurance ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Workplace.fromMap(Map<String, dynamic> map) {
    return Workplace(
      id: map['id'],
      name: map['name'],
      payday: map['payday'],
      color: Color(map['color']),
      deductTax: map['deduct_tax'] == 1,
      deductInsurance: map['deduct_insurance'] == 1,
      isActive: map['is_active'] == 1,
    );
  }

  // API 연동시 필요
  factory Workplace.fromJson(Map<String, dynamic> json) {
    return Workplace(
      id: json['id'],
      name: json['name'],
      payday: json['payday'],
      color: Color(json['color']),
      deductTax: json['deduct_tax'] ?? false,
      deductInsurance: json['deduct_insurance'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }
}