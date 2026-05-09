import 'package:flutter/foundation.dart';

@immutable
class Goal {
  final String name;
  final String amount;
  final String spent;
  final String description;
  final String currentDate;
  final String goalDate;

  const Goal({
    required this.name,
    required this.amount,
    required this.spent,
    required this.description,
    required this.currentDate,
    required this.goalDate
  });
}