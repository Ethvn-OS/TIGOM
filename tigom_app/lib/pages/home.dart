import 'package:flutter/material.dart';
import 'package:tigom_app/pages/plans.dart';
import 'package:tigom_app/models/goal.dart';
import 'package:tigom_app/widgets/goalwidgets.dart';
import 'package:tigom_app/pages/profile.dart';
import 'package:tigom_app/widgets/spendings_card.dart';
import 'package:tigom_app/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Savings
  int selectedSavingsIndex = 0;
  final List<String> savingsTab = ['Physical Cash', 'E-Wallet', 'Bank'];
  final List<String> accountTypes = ['cash', 'ewallet', 'bank'];
  Map<String, double> accountBalances = {'cash': 0, 'ewallet': 0, 'bank': 0};
  Map<String, String> accountIds = {};
  bool loadingAccounts = true;

  // Goals
  int currentGoalIndex = 0;
  List<Goal> goals = [];
  bool loadingGoals = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _loadGoals();
  }

  Future<void> _loadAccounts() async {
    setState(() => loadingAccounts = true);
    try {
      final accounts = await SupabaseService.getAccounts();
      final Map<String, double> balances = {
        'cash': 0,
        'ewallet': 0,
        'bank': 0
      };
      final Map<String, String> ids = {};
      for (final a in accounts) {
        final type = (a['account_type'] as String).toLowerCase();
        if (balances.containsKey(type)) {
          balances[type] = (a['balance'] as num).toDouble();
          ids[type] = a['account_id'] as String;
        }
      }
      setState(() {
        accountBalances = balances;
        accountIds = ids;
        loadingAccounts = false;
      });
    } catch (e) {
      setState(() => loadingAccounts = false);
    }
  }

  Future<void> _loadGoals() async {
    setState(() => loadingGoals = true);
    try {
      final loaded = await SupabaseService.getGoals();
      setState(() {
        goals = loaded;
        loadingGoals = false;
      });
    } catch (e) {
      setState(() => loadingGoals = false);
    }
  }

  double getCurrentBalance() =>
      accountBalances.values.fold(0.0, (sum, v) => sum + v);

  String formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final withCommas = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$withCommas.${parts[1]}';
  }

  void nextGoal() {
    if (currentGoalIndex <= goals.length)
      setState(() => currentGoalIndex++);
  }

  void previousGoal() {
    if (currentGoalIndex > 0) setState(() => currentGoalIndex--);
  }

  void _showEditBalanceModal(String accountType, String label) {
    final type = accountType.toLowerCase();
    final currentBalance = accountBalances[type] ?? 0.0;
    final controller =
        TextEditingController(text: currentBalance.toStringAsFixed(2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF9E9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit $label Balance',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3867),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                style: const TextStyle(color: Color(0xFF1D3867)),
                decoration: InputDecoration(
                  labelText: 'Amount (Php)',
                  labelStyle:
                      const TextStyle(color: Color(0xFF1D3867)),
                  prefixIcon: const Icon(Icons.payments_outlined,
                      color: Color(0xFF1D3867)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Color(0xFF1D3867)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newBalance =
                        double.tryParse(controller.text) ??
                            currentBalance;
                    final id =
                        accountIds[type] ?? const Uuid().v4();
                    try {
                      await SupabaseService.upsertAccount(
                        accountId: id,
                        accountType: type,
                        balance: newBalance,
                      );
                      await _loadAccounts();
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                              content: Text('Error saving: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D3867),
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Color(0xFFFFF9E9),
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGoalModal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController(text: '0');
    DateTime? goalDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add New Goal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3867),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                _modalField(
                  controller: titleController,
                  label: 'Goal Title',
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),

                // Target amount
                _modalField(
                  controller: targetController,
                  label: 'Target Amount (Php)',
                  icon: Icons.savings_outlined,
                  isNumber: true,
                ),
                const SizedBox(height: 16),

                // Current amount
                _modalField(
                  controller: currentController,
                  label: 'Current Amount (Php)',
                  icon: Icons.payments_outlined,
                  isNumber: true,
                ),
                const SizedBox(height: 16),

                // Goal date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now()
                          .add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF1D3867),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setModalState(() => goalDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: Color(0xFF1D3867)),
                        const SizedBox(width: 12),
                        Text(
                          goalDate == null
                              ? 'Pick Goal Date'
                              : '${goalDate!.month.toString().padLeft(2, '0')}-${goalDate!.day.toString().padLeft(2, '0')}-${goalDate!.year}',
                          style: TextStyle(
                            color: goalDate == null
                                ? Colors.grey
                                : const Color(0xFF1D3867),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          targetController.text.isEmpty ||
                          goalDate == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill all fields')),
                        );
                        return;
                      }
                      try {
                        await SupabaseService.upsertGoal(
                          goalId: const Uuid().v4(),
                          title: titleController.text,
                          targetAmount: double.tryParse(
                                  targetController.text) ??
                              0,
                          currentAmount: double.tryParse(
                                  currentController.text) ??
                              0,
                          goalDate: goalDate!.toIso8601String(),
                        );
                        await _loadGoals();
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Error saving: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3867),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'SAVE GOAL',
                      style: TextStyle(
                        color: Color(0xFFFFF9E9),
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Color(0xFF1D3867)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1D3867)),
        prefixIcon: Icon(icon, color: const Color(0xFF1D3867)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1D3867)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentType = accountTypes[selectedSavingsIndex];
    final amount = accountBalances[currentType] ?? 0.0;
    final currentBalanceText = formatMoney(getCurrentBalance());

    return Scaffold(
      backgroundColor: const Color(0xFFfff9e9),
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'TIGOM',
          style: TextStyle(
            fontFamily: 'RuslanDisplay',
            color: Color(0xFFE2520B),
            fontSize: 40,
          ),
        ),
        backgroundColor: const Color(0xFFfff9e9),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Current Balance Box
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1d3867),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage('assets/flag_pattern.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Balance:',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          loadingAccounts
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Php $currentBalanceText',
                                  style: const TextStyle(
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
                const SizedBox(height: 24),
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
                      margin:
                          const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfff9e9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children:
                            List.generate(savingsTab.length, (index) {
                          final isSelected =
                              index == selectedSavingsIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => selectedSavingsIndex = index),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1D3867)
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(20),
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
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFfce7ba),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Php',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF1D3867)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatMoney(amount),
                              style: const TextStyle(
                                fontSize: 54,
                                height: 1.0,
                                color: Color(0xFF1D3867),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditBalanceModal(
                          currentType,
                          savingsTab[selectedSavingsIndex],
                        ),
                        child: Container(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Goals Box
            Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFfce7ba),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: loadingGoals
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF1D3867)),
                        )
                      : Row(
                          children: [
                            IconButton(
                              onPressed: previousGoal,
                              icon: const Icon(Icons.chevron_left),
                              color: const Color(0xFF1D3867),
                            ),
                            Expanded(
                              child: currentGoalIndex < goals.length
                                  ? GoalContent(
                                      goal: goals[currentGoalIndex])
                                  : AddNewGoalContent(
                                      onTap: _showAddGoalModal,
                                    ),
                            ),
                            IconButton(
                              onPressed: nextGoal,
                              icon: const Icon(Icons.chevron_right),
                              color: const Color(0xFF1D3867),
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
        backgroundColor: const Color(0xFF1d3867),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => PlansPage(goals: goals)),
            );
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const EditProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_road), label: 'Plans'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}