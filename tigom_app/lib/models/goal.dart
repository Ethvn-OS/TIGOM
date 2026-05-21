import 'package:flutter/foundation.dart';

@immutable
class Goal {
  final String? goalId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String description;
  final String currentDate;
  final String goalDate;
  final String status;

  const Goal({
    this.goalId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.description,
    required this.currentDate,
    required this.goalDate,
    this.status = 'active',
  });

  // from Supabase row
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      goalId: map['goal_id'] as String?,
      name: map['title'] as String? ?? '',
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0,
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0,
      description: map['title'] as String? ?? '',
      currentDate: _formatDate(map['created_at'] as String?),
      goalDate: _formatDate(map['goal_date'] as String?),
      status: map['status'] as String? ?? 'active',
    );
  }

  static String _formatDate(String? raw) {
    if (raw == null) return '';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  String get progressLabel =>
      '${(progressPercent * 100).toStringAsFixed(3)}%';

  String get amountLabel =>
      '${_fmt(currentAmount)}/${_fmt(targetAmount)}';

  static String _fmt(double v) {
    final fixed = v.toStringAsFixed(2);
    final parts = fixed.split('.');
    final withCommas = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$withCommas.${parts[1]}';
  }
}