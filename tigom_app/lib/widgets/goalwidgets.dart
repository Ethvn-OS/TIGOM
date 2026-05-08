import 'package:flutter/material.dart';
import 'package:tigom_app/models/goal.dart';

class GoalContent extends StatelessWidget {
  final Goal goal;
  const GoalContent({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 18, color: Color(0xFF1D3867)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Current date\n${goal.currentDate}',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D3867)),
                ),
              ),
              Icon(Icons.flag, size: 18, color: Color(0xFF1D3867)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Goal Date\n${goal.goalDate}',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D3867)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF1D3867),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text(
                '40.234%',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE2520B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '3000.00/7500.00',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFC9A15A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.40234,
              minHeight: 10,
              backgroundColor: Color(0xFFF7E6BF),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC63A2B)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddNewGoalContent extends StatelessWidget {
  const AddNewGoalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add a New Goal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D3867),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 190,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F1D8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1D3867),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 22,
                color: Color(0xFF1D3867),
              ),
            ),
          ),
        ],
      ),
    );
  }
}