import 'package:flutter/material.dart';
import 'package:tigom_app/models/spending_entry.dart';
import 'package:tigom_app/pages/home.dart';
import 'package:tigom_app/pages/plans.dart';
import 'package:tigom_app/data/goals_data.dart';
import 'package:tigom_app/pages/profile.dart';

// ─── Category config ───────────────────────────────────────────────────────

enum SpendCategory { food, gas, items, leisure }

extension SpendCategoryExt on SpendCategory {
  String get label {
    switch (this) {
      case SpendCategory.food:    return 'FOOD';
      case SpendCategory.gas:     return 'GAS';
      case SpendCategory.items:   return 'ITEMS';
      case SpendCategory.leisure: return 'LEISURE';
    }
  }

  Color get color {
    switch (this) {
      case SpendCategory.food:    return const Color(0xFF1D3867); // navy
      case SpendCategory.gas:     return const Color(0xFFC63A2B); // red
      case SpendCategory.items:   return const Color(0xFFE2520B); // orange
      case SpendCategory.leisure: return const Color(0xFFCB9C3E); // gold
    }
  }
}

// ─── History Page ──────────────────────────────────────────────────────────

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  SpendCategory _selectedCategory = SpendCategory.food;

  final Map<SpendCategory, List<SpendingEntry>> _data = {
    SpendCategory.food:    [],
    SpendCategory.gas:     [],
    SpendCategory.items:   [],
    SpendCategory.leisure: [],
  };

  List<SpendingEntry> get _currentEntries => _data[_selectedCategory]!;

  double _sumForPeriod(SpendCategory cat, Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return _data[cat]!
        .where((e) => e.createdAt.isAfter(cutoff))
        .fold(0.0, (s, e) => s + e.total);
  }

  double get _todayTotal =>
      _sumForPeriod(_selectedCategory, const Duration(days: 1));
  double get _weekTotal =>
      _sumForPeriod(_selectedCategory, const Duration(days: 7));
  double get _monthTotal =>
      _sumForPeriod(_selectedCategory, const Duration(days: 30));

  String _fmt(double v) => v == v.truncate()
      ? v.toStringAsFixed(1)
      : v.toStringAsFixed(2);

  String _fmtDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';

  void _openAddSheet({SpendingEntry? existing, int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpendingFormSheet(
        categoryColor: _selectedCategory.color,
        initial: existing,
        onSave: (entry) {
          setState(() {
            if (editIndex != null) {
              _currentEntries[editIndex] = entry;
            } else {
              _currentEntries.add(entry);
            }
          });
        },
      ),
    );
  }

  void _deleteEntry(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete entry?',
          style: TextStyle(color: Color(0xFF1D3867)),
        ),
        content: const Text(
          'This spending entry will be removed.',
          style: TextStyle(color: Color(0xFF1D3867)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF1D3867))),
          ),
          TextButton(
            onPressed: () {
              setState(() => _currentEntries.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFC63A2B))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _selectedCategory.color;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E9),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFFFF9E9),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'TIGOM',
          style: TextStyle(
            fontFamily: 'RuslanDisplay',
            color: Color(0xFFE2520B),
            fontSize: 40,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    color: Color(0xFF1D3867), size: 26),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D3867),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // ── Spendings card ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7BA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 14, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.attach_money,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Spendings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3867),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category tab bar
                  _CategoryTabBar(
                    selected: _selectedCategory,
                    onSelect: (c) => setState(() => _selectedCategory = c),
                  ),

                  // Category body
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _CategoryBody(
                      key: ValueKey(_selectedCategory),
                      color: catColor,
                      todayTotal: _todayTotal,
                      weekTotal: _weekTotal,
                      monthTotal: _monthTotal,
                      entries: _currentEntries,
                      fmt: _fmt,
                      fmtDate: _fmtDate,
                      onEdit: (i) => _openAddSheet(
                          existing: _currentEntries[i], editIndex: i),
                      onDelete: _deleteEntry,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Add to Spendings button ─────────────────────────────────
            GestureDetector(
              onTap: () => _openAddSheet(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7BA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.attach_money,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add to Spendings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3867),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1d3867),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => PlansPage(goals: goalsData)));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditProfilePage()));
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

// ─── Category Tab Bar ──────────────────────────────────────────────────────

class _CategoryTabBar extends StatelessWidget {
  final SpendCategory selected;
  final ValueChanged<SpendCategory> onSelect;

  const _CategoryTabBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cats = SpendCategory.values;
    return Row(
      children: cats.map((cat) {
        final isSelected = cat == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? cat.color : const Color(0xFFE8D5A3),
              ),
              child: Center(
                child: Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF1D3867),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Category Body ─────────────────────────────────────────────────────────

class _CategoryBody extends StatelessWidget {
  final Color color;
  final double todayTotal;
  final double weekTotal;
  final double monthTotal;
  final List<SpendingEntry> entries;
  final String Function(double) fmt;
  final String Function(DateTime) fmtDate;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  const _CategoryBody({
    super.key,
    required this.color,
    required this.todayTotal,
    required this.weekTotal,
    required this.monthTotal,
    required this.entries,
    required this.fmt,
    required this.fmtDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final List<_FlatTransaction> allTx = [];
    for (int ei = 0; ei < entries.length; ei++) {
      final e = entries[ei];
      for (final t in e.transactions) {
        allTx.add(_FlatTransaction(
          title: t.title,
          amount: t.amount,
          date: e.createdAt,
          entryIndex: ei,
        ));
      }
    }
    allTx.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Totals row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Php',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fmt(todayTotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _PeriodLabel(label: 'Today'),
                  SizedBox(height: 4),
                  _PeriodLabel(label: 'This Week'),
                  SizedBox(height: 4),
                  _PeriodLabel(label: 'This Month'),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmt(weekTotal),
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                Text(fmt(monthTotal),
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // Recent Transactions header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Php',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 8),

          if (allTx.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No transactions yet.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            )
          else
            ...allTx.take(5).map((tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(fmtDate(tx.date),
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(fmt(tx.amount),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ],
                  ),
                )),

          // Edit / Delete row
          if (entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => onEdit(entries.length - 1),
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => onDelete(entries.length - 1),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodLabel extends StatelessWidget {
  final String label;
  const _PeriodLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(color: Colors.white70, fontSize: 12));
  }
}

class _FlatTransaction {
  final String title;
  final double amount;
  final DateTime date;
  final int entryIndex;
  _FlatTransaction(
      {required this.title,
      required this.amount,
      required this.date,
      required this.entryIndex});
}

// ─── Spending Form Sheet ───────────────────────────────────────────────────

class _SpendingFormSheet extends StatefulWidget {
  final Color categoryColor;
  final SpendingEntry? initial;
  final ValueChanged<SpendingEntry> onSave;

  const _SpendingFormSheet({
    required this.categoryColor,
    required this.onSave,
    this.initial,
  });

  @override
  State<_SpendingFormSheet> createState() => _SpendingFormSheetState();
}

class _SpendingFormSheetState extends State<_SpendingFormSheet> {
  late TextEditingController _titleCtrl;
  late List<TextEditingController> _txTitles;
  late List<TextEditingController> _txAmounts;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleCtrl = TextEditingController(text: widget.initial!.title);
      _txTitles = widget.initial!.transactions
          .map((t) => TextEditingController(text: t.title))
          .toList();
      _txAmounts = widget.initial!.transactions
          .map((t) => TextEditingController(text: t.amount.toString()))
          .toList();
    } else {
      _titleCtrl = TextEditingController();
      _txTitles = [TextEditingController()];
      _txAmounts = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final c in _txTitles) c.dispose();
    for (final c in _txAmounts) c.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _txTitles.add(TextEditingController());
      _txAmounts.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_txTitles.length == 1) return;
    setState(() {
      _txTitles[i].dispose();
      _txAmounts[i].dispose();
      _txTitles.removeAt(i);
      _txAmounts.removeAt(i);
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title.')),
      );
      return;
    }

    final transactions = <TransactionItem>[];
    for (int i = 0; i < _txTitles.length; i++) {
      final t = _txTitles[i].text.trim();
      final a = double.tryParse(_txAmounts[i].text.trim()) ?? 0;
      if (t.isNotEmpty) transactions.add(TransactionItem(title: t, amount: a));
    }

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one transaction.')),
      );
      return;
    }

    widget.onSave(SpendingEntry(
      title: title,
      transactions: transactions,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9E9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Spendings form card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7BA),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.attach_money,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'New Spendings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3867),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title field
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                        color: Color(0xFF1D3867), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a title',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF1D3867)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Transaction rows
                  ...List.generate(_txTitles.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: _txTitles[i],
                              style: const TextStyle(
                                  color: Color(0xFF1D3867), fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Transaction Title',
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1D3867)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: TextField(
                              controller: _txAmounts[i],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(
                                  color: Color(0xFF1D3867), fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Transaction Amount',
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1D3867)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          if (_txTitles.length > 1)
                            GestureDetector(
                              onTap: () => _removeRow(i),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.close,
                                    size: 18, color: Color(0xFFC63A2B)),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Add more transactions
                  GestureDetector(
                    onTap: _addRow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Add more transactions',
                        style: TextStyle(
                            color: Color(0xFF1D3867), fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Trash (clear all)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _titleCtrl.clear();
                          for (final c in _txTitles) c.clear();
                          for (final c in _txAmounts) c.clear();
                        });
                      },
                      child: const Icon(Icons.delete_outline,
                          color: Color(0xFF1D3867), size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Add to Spendings button
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7BA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.attach_money,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add to Spendings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3867),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}