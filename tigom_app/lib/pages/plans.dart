import 'package:flutter/material.dart';
import 'package:tigom_app/pages/home.dart';
import 'package:tigom_app/models/goal.dart';
import 'package:tigom_app/widgets/goalwidgets.dart';

class PlansPage extends StatelessWidget {
  final List<Goal> goals;

  const PlansPage({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff9e9),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          'TIGOM',
          style: TextStyle(
            fontFamily: 'RuslanDisplay',
            color: Color(0xFFE2520B),
            fontSize: 40,
          )
        ),
        backgroundColor: Color(0xFFfff9e9),
        elevation: 0.0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
        children: [
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 160,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFfce7ba),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GoalContent(goal: goal),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFfce7ba),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const AddNewGoalContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1d3867),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_road), label: 'Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}