import 'package:flutter/material.dart';
import 'package:tigom_app/pages/plans.dart';
import 'package:tigom_app/data/goals_data.dart';
import 'package:tigom_app/models/goal.dart';
import 'package:tigom_app/widgets/goalwidgets.dart';
import 'package:tigom_app/pages/profile.dart';
import 'package:tigom_app/widgets/spendings_card.dart';
import 'package:tigom_app/pages/history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // For Savings Box
  int selectedSavingsIndex = 1;

  final List<String> savingsTab = ['Physical Cash', 'E-Wallet', 'Bank'];
  final List<double> savingsAmount = [120.00, 307.00, 2850.00];

  double getCurrentBalance() {
    return savingsAmount.fold(0.0, (sum, value) => sum + value);
  }

  String formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final withCommas = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$withCommas.$decimal';
  }

  void selectSavingsTab(int index) {
    setState(() {
      selectedSavingsIndex = index;
    });
  }

  // For Goals Box
  int currentGoalIndex = 0;

  final List<Goal> goals = goalsData;

  void nextGoal() {
    if (currentGoalIndex < goals.length) {
      setState(() {
        currentGoalIndex++;
      });
    }
  }

  void previousGoal() {
    if (currentGoalIndex > 0) {
      setState(() {
        currentGoalIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = savingsAmount[selectedSavingsIndex];
    final currentBalanceText = formatMoney(getCurrentBalance());
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
          ),
        ),
        backgroundColor: Color(0xFFfff9e9),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Current Balance Box
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0XFF1d3867),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Left Side
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage('assets/flag_pattern.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Right side
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Php $currentBalanceText',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Savings Box
            Column(
              children: [
                SizedBox(height: 24),
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFe4be74),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfff9e9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: List.generate(savingsTab.length, (index) {
                          final isSelected = index == selectedSavingsIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => selectSavingsTab(index),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1D3867)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  savingsTab[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1D3867),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFfce7ba),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Php',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF1D3867),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatMoney(amount),
                              style: TextStyle(
                                fontSize: 54,
                                height: 1.0,
                                color: Color(0xFF1D3867),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1D3867),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Color(0xFF1D3867),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Goals Navigation Box
            Column(
              children: [
                SizedBox(height: 24),
                Container(
                  height: 160,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFfce7ba),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: previousGoal,
                        icon: Icon(Icons.chevron_left),
                        color: Color(0xFF1D3867),
                      ),
                      Expanded(
                        child: currentGoalIndex < goals.length
                            ? GoalContent(goal: goals[currentGoalIndex])
                            : AddNewGoalContent(),
                      ),
                      IconButton(
                        onPressed: nextGoal,
                        icon: Icon(Icons.chevron_right),
                        color: Color(0xFF1D3867),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Spendings Card
            const SizedBox(height: 24),
            const SpendingsCard(),
            const SizedBox(height: 24),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0XFF1d3867),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PlansPage(goals: goals)),
            );
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
          }
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const EditProfilePage(),
              ),
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