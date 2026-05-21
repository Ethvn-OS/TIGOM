import 'package:flutter/material.dart';
import 'package:tigom_app/pages/home.dart';
import 'package:tigom_app/pages/profile.dart';
import 'package:tigom_app/models/goal.dart';
import 'package:tigom_app/widgets/goalwidgets.dart';
import 'package:tigom_app/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key, List<Goal>? goals}) : _initialGoals = goals;

  final List<Goal>? _initialGoals;

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  List<Goal> goals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (widget._initialGoals != null) {
      goals = widget._initialGoals!;
      loading = false;
    }
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => loading = true);
    try {
      final loaded = await SupabaseService.getGoals();
      setState(() {
        goals = loaded;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
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
                _modalField(
                  controller: titleController,
                  label: 'Goal Title',
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),
                _modalField(
                  controller: targetController,
                  label: 'Target Amount (Php)',
                  icon: Icons.savings_outlined,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _modalField(
                  controller: currentController,
                  label: 'Current Amount (Php)',
                  icon: Icons.payments_outlined,
                  isNumber: true,
                ),
                const SizedBox(height: 16),

                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate:
                          DateTime.now().add(const Duration(days: 30)),
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
                      border: Border.all(color: Colors.grey.shade400),
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
                              : '${goalDate!.month.toString().padLeft(2, '0')}-'
                                  '${goalDate!.day.toString().padLeft(2, '0')}-'
                                  '${goalDate!.year}',
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
                              content: Text('Please fill all fields')),
                        );
                        return;
                      }
                      try {
                        await SupabaseService.upsertGoal(
                          goalId: const Uuid().v4(),
                          title: titleController.text,
                          targetAmount:
                              double.tryParse(targetController.text) ?? 0,
                          currentAmount:
                              double.tryParse(currentController.text) ?? 0,
                          goalDate: goalDate!.toIso8601String(),
                        );
                        await _loadGoals();
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error saving: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3867),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _showEditGoalModal(Goal goal) {
    final titleController = TextEditingController(text: goal.name);
    final targetController =
        TextEditingController(text: goal.targetAmount.toStringAsFixed(2));
    final currentController =
        TextEditingController(text: goal.currentAmount.toStringAsFixed(2));
    DateTime? goalDate = DateTime.tryParse(
      goal.goalDate.replaceAllMapped(
        RegExp(r'(\d{2})-(\d{2})-(\d{4})'),
        (m) => '${m[3]}-${m[1]}-${m[2]}',
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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

                // Header with delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Goal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D3867),
                        letterSpacing: 1,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (goal.goalId == null) return;
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (dCtx) => AlertDialog(
                            backgroundColor: const Color(0xFFFFF9E9),
                            title: const Text('Delete Goal',
                                style:
                                    TextStyle(color: Color(0xFF1D3867))),
                            content: const Text(
                                'Are you sure you want to delete this goal?',
                                style:
                                    TextStyle(color: Color(0xFF1D3867))),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dCtx, false),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Color(0xFF1D3867))),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dCtx, true),
                                child: const Text('Delete',
                                    style:
                                        TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await SupabaseService.deleteGoal(goal.goalId!);
                          await _loadGoals();
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _modalField(
                    controller: titleController,
                    label: 'Goal Title',
                    icon: Icons.flag_outlined),
                const SizedBox(height: 16),
                _modalField(
                    controller: targetController,
                    label: 'Target Amount (Php)',
                    icon: Icons.savings_outlined,
                    isNumber: true),
                const SizedBox(height: 16),
                _modalField(
                    controller: currentController,
                    label: 'Current Amount (Php)',
                    icon: Icons.payments_outlined,
                    isNumber: true),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: goalDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 365)),
                      lastDate: DateTime(2100),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: Color(0xFF1D3867)),
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
                      border: Border.all(color: Colors.grey.shade400),
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
                              : '${goalDate!.month.toString().padLeft(2, '0')}-'
                                  '${goalDate!.day.toString().padLeft(2, '0')}-'
                                  '${goalDate!.year}',
                          style: const TextStyle(
                              color: Color(0xFF1D3867)),
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
                      try {
                        await SupabaseService.upsertGoal(
                          goalId: goal.goalId ?? const Uuid().v4(),
                          title: titleController.text,
                          targetAmount:
                              double.tryParse(targetController.text) ?? 0,
                          currentAmount:
                              double.tryParse(currentController.text) ?? 0,
                          goalDate: goalDate?.toIso8601String() ??
                              DateTime.now().toIso8601String(),
                        );
                        await _loadGoals();
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error saving: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3867),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'SAVE CHANGES',
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
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D3867)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
              children: [
                ...goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () => _showEditGoalModal(goal),
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfce7ba),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AddNewGoalContent(onTap: _showAddGoalModal),
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
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 3){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
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