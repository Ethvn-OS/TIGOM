import 'package:flutter/material.dart';

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

  final List<Map<String, String>> goals = [
    {
      'name': 'Laag sa Singapore',
      'amount': '1,500.00',
      'spent': '500.00',
      'description': 'Travel to Singapore',
    },
    // More goals here
  ];

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
          )
        ),
        backgroundColor: Color(0xFFfff9e9),
        elevation: 0.0,
      ),
      body: Column( // Current Balance Box
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                  offset: Offset(0,3)
                )
              ]
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
                            fontWeight: FontWeight.bold
                          )
                        )
                      ],
                    )
                  )
                )
              ]
            )
          ),
          Column( // Savings Box (Physical Cash, E - Wallet, Bank)
            children: [
              SizedBox(height: 24),
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFe4be74),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)
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
                                color: isSelected ? const Color(0xFF1D3867) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                savingsTab[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : const Color(0xFF1D3867),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )
                )
              ),
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFfce7ba),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)
                  )
                ),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Php',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1D3867)
                        )
                      )
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
                              fontWeight: FontWeight.w700
                            )
                          )
                        )
                      )
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1D3867),
                          width: 2,
                        )
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFF1D3867)
                      )
                    )
                  ],
                )
              )
            ],
          ),
          Column( // Goals Navigation Box
            children: [
              SizedBox(height: 24),
              Container(
                height: 160,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFfce7ba),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Row(
                  children: [
                    IconButton( // Left arrow button
                      onPressed: previousGoal,
                      icon: Icon(Icons.chevron_left),
                      color: Color(0xFF1D3867),
                    ),
                    Expanded( // Content (Goal or Add New Goal)
                      child: currentGoalIndex < goals.length ? GoalContent(goal: goals[currentGoalIndex]) : AddNewGoalContent(),
                    ),
                    IconButton( // Right arrow button
                      onPressed: nextGoal,
                      icon: Icon(Icons.chevron_right),
                      color: Color(0xFF1D3867)
                    ),
                  ],
                ),
              )
            ]
          )
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0XFF1d3867),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
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

class GoalContent extends StatelessWidget {
  final Map<String, String> goal;

  const GoalContent({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: Color(0xFF1D3867)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Current date\nJanuary 26, 2025',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D3867)),
                ),
              ),
              const Icon(Icons.flag, size: 18, color: Color(0xFF1D3867)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Goal Date\nJanuary 21, 2026',
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
                    goal['name'] ?? 'Laag sa Singapore',
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
            child: LinearProgressIndicator(
              value: 0.40234,
              minHeight: 10,
              backgroundColor: const Color(0xFFF7E6BF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC63A2B)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddNewGoalContent extends StatelessWidget {
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


/*

Column( // Savings Box (Physical Cash, E - Wallet, Bank)
  children: [
    SizedBox(height: 24),
    Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFFe4be74),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16)
        )
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
                  color: isSelected ? const Color(0xFF1D3867) : const Color(0xFFfff9e9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  savingsTab[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : const Color(0xFF1D3867),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
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
          bottomRight: Radius.circular(16)
        )
      ),
      child: Row(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Php',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF1D3867)
              )
            )
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 54,
                    height: 1.0,
                    color: Color(0xFF1D3867),
                    fontWeight: FontWeight.w700
                  )
                )
              )
            )
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1D3867),
                width: 2,
              )
            ),
            child: const Icon(
              Icons.add,
              size: 18,
              color: Color(0xFF1D3867)
            )
          )
        ],
      )
    )
  ],
),

*/