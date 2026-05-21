import 'package:tigom_app/models/goal.dart';

// fallback static data — only used if Supabase hasn't loaded yet
const List<Goal> goalsData = [
  Goal(
    name: 'Laag sa Singapore',
    targetAmount: 1500.00,
    currentAmount: 500.00,
    description: 'Travel to Singapore',
    currentDate: '03-03-2026',
    goalDate: '05-16-2026',
  ),
  Goal(
    name: 'Car',
    targetAmount: 150.00,
    currentAmount: 20.00,
    description: 'First car fund',
    currentDate: '03-03-2026',
    goalDate: '12-24-2030',
  ),
];