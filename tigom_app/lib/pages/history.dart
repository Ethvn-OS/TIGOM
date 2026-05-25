import 'package:flutter/material.dart';
import 'package:tigom_app/models/spending_entry.dart';
import 'package:tigom_app/pages/home.dart';
import 'package:tigom_app/pages/plans.dart';
import 'package:tigom_app/pages/profile.dart';
import 'package:tigom_app/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

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

  String get supabaseName {
    switch (this) {
      case SpendCategory.food:    return 'Food';
      case SpendCategory.gas:     return 'Transport';
      case SpendCategory.items:   return 'Shopping';
      case SpendCategory.leisure: return 'Leisure';
    }
  }

  Color get color {
    switch (this) {
      case SpendCategory.food:    return const Color(0xFF1D3867);
      case SpendCategory.gas:     return const Color(0xFFC63A2B);
      case SpendCategory.items:   return const Color(0xFFE2520B);
      case SpendCategory.leisure: return const Color(0xFFCB9C3E);
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
  bool _loading = false;

  Map<String, String> _categoryMap = {};
  String? _accountId;

  final Map<SpendCategory, List<SpendingEntry>> _data = {
    SpendCategory.food:    [],
    SpendCategory.gas:     [],
    SpendCategory.items:   [],
    SpendCategory.leisure: [],
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      _categoryMap = await SupabaseService.getCategoryMap();
      _accountId = await SupabaseService.getFirstAccountId();
      await _loadCategory(_selectedCategory);
    } catch (e) {
      debugPrint('Init error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _loadCategory(SpendCategory cat) async {
    try {
      final rows = await SupabaseService.getTransactionsByCategory(
          cat.supabaseName);
      final entries = rows.map((row) => SpendingEntry(
            title: row['description'] as String? ?? cat.supabaseName,
            transactions: [TransactionItem.fromMap(row)],
            createdAt: DateTime.tryParse(
                    row['transaction_date'] as String? ?? '') ??
                DateTime.now(),
          )).toList();
      setState(() => _data[cat] = entries);
    } catch (e) {
      debugPrint('Load category error: $e');
    }
  }

  List<SpendingEntry> get _currentEntries => _data[_selectedCategory]!;

  double _sumForPeriod(List<SpendingEntry> entries, Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return entries
        .where((e) => e.createdAt.isAfter(cutoff))
        .fold(0.0, (s, e) => s + e.total);
  }

  String _fmt(double v) => v == v.truncate()
      ? v.toStringAsFixed(1)
      : v.toStringAsFixed(2);

  String _fmtDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';

  void _openAddSheet({
    SpendingEntry? existing,
    int? editIndex,
    SpendCategory? forceCat,
  }) {
    final cat = forceCat ?? _selectedCategory;
    final catName = cat.supabaseName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpendingFormSheet(
        categoryColor: cat.color,
        categoryName: catName,
        initial: existing,
        onSave: (entry) async {
          final categoryId = _categoryMap[catName];
          if (categoryId == null || _accountId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Category "$catName" not found in database')),
            );
            return;
          }

          try {
            if (editIndex != null) {
              final old = _data[cat]![editIndex];
              for (final t in old.transactions) {
                if (t.transactionId != null) {
                  await SupabaseService.deleteTransaction(
                      t.transactionId!);
                }
              }
            }

            for (final tx in entry.transactions) {
              await SupabaseService.saveTransaction(
                transactionId: const Uuid().v4(),
                categoryId: categoryId,
                accountId: _accountId!,
                description: tx.title,
                amount: tx.amount,
                type: 'expense',
              );
            }

            await _loadCategory(cat);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteEntry(int index, {SpendCategory? cat}) {
    final entries = _data[cat ?? _selectedCategory]!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9E9),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete entry?',
            style: TextStyle(color: Color(0xFF1D3867))),
        content: const Text('This spending entry will be removed.',
            style: TextStyle(color: Color(0xFF1D3867))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF1D3867))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                for (final t in entries[index].transactions) {
                  if (t.transactionId != null) {
                    await SupabaseService.deleteTransaction(
                        t.transactionId!);
                  }
                }
                await _loadCategory(cat ?? _selectedCategory);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting: $e')),
                  );
                }
              }
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
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF1D3867)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  // Spendings card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7BA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 14, bottom: 10),
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

                        _CategoryTabBar(
                          selected: _selectedCategory,
                          onSelect: (c) async {
                            setState(() => _selectedCategory = c);
                            await _loadCategory(c);
                          },
                        ),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _CategoryBody(
                            key: ValueKey(_selectedCategory),
                            color: _selectedCategory.color,
                            todayTotal: _sumForPeriod(
                                _currentEntries,
                                const Duration(days: 1)),
                            weekTotal: _sumForPeriod(
                                _currentEntries,
                                const Duration(days: 7)),
                            monthTotal: _sumForPeriod(
                                _currentEntries,
                                const Duration(days: 30)),
                            entries: _currentEntries,
                            fmt: _fmt,
                            fmtDate: _fmtDate,
                            onAdd: () => _openAddSheet(
                                forceCat: _selectedCategory),
                            onEdit: (i) => _openAddSheet(
                                existing: _currentEntries[i],
                                editIndex: i,
                                forceCat: _selectedCategory),
                            onDelete: (i) =>
                                _deleteEntry(i, cat: _selectedCategory),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Add to Spendings button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _openAddSheet(forceCat: _selectedCategory),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add to Spendings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D3867),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomePage()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const PlansPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const EditProfilePage()));
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

// ─── Category Tab Bar ──────────────────────────────────────────────────────

class _CategoryTabBar extends StatelessWidget {
  final SpendCategory selected;
  final ValueChanged<SpendCategory> onSelect;

  const _CategoryTabBar(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SpendCategory.values.map((cat) {
        final isSelected = cat == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color
                    : const Color(0xFFE8D5A3),
              ),
              child: Center(
                child: Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1D3867),
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
  final VoidCallback onAdd;
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
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final List<_FlatTransaction> allTx = [];
    for (int ei = 0; ei < entries.length; ei++) {
      for (final t in entries[ei].transactions) {
        allTx.add(_FlatTransaction(
          title: t.title,
          amount: t.amount,
          date: entries[ei].createdAt,
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
          // Totals
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Php',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14)),
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
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                Text(fmt(monthTotal),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // Transactions header + add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Add',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (allTx.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No transactions yet.',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 13)),
            )
          else
            ...allTx.take(5).map((tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(tx.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(fmtDate(tx.date),
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(fmt(tx.amount),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onEdit(tx.entryIndex),
                        child: const Icon(Icons.edit_outlined,
                            color: Colors.white54, size: 16),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onDelete(tx.entryIndex),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white54, size: 16),
                      ),
                    ],
                  ),
                )),
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
        style:
            const TextStyle(color: Colors.white70, fontSize: 12));
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
  final String categoryName;
  final SpendingEntry? initial;
  final ValueChanged<SpendingEntry> onSave;

  const _SpendingFormSheet({
    required this.categoryColor,
    required this.categoryName,
    required this.onSave,
    this.initial,
  });

  @override
  State<_SpendingFormSheet> createState() => _SpendingFormSheetState();
}

class _SpendingFormSheetState extends State<_SpendingFormSheet> {
  
  late List<TextEditingController> _txTitles;
  late List<TextEditingController> _txAmounts;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
     
      _txTitles = widget.initial!.transactions
          .map((t) => TextEditingController(text: t.title))
          .toList();
      _txAmounts = widget.initial!.transactions
          .map((t) =>
              TextEditingController(text: t.amount.toString()))
          .toList();
    } else {
      
      _txTitles = [TextEditingController()];
      _txAmounts = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    
    for (final c in _txTitles) c.dispose();
    for (final c in _txAmounts) c.dispose();
    super.dispose();
  }

  void _addRow() => setState(() {
        _txTitles.add(TextEditingController());
        _txAmounts.add(TextEditingController());
      });

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
  final transactions = <TransactionItem>[];
  for (int i = 0; i < _txTitles.length; i++) {
    final t = _txTitles[i].text.trim();
    final a = double.tryParse(_txAmounts[i].text.trim()) ?? 0;
    if (t.isNotEmpty)
      transactions.add(TransactionItem(title: t, amount: a));
  }

  if (transactions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one transaction.')));
    return;
  }

  widget.onSave(SpendingEntry(
    title: transactions.first.title, // <-- uses first tx title
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
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

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7BA),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.categoryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.attach_money,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add to ${widget.categoryName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D3867),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  

                  ...List.generate(
                      _txTitles.length,
                      (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: _formField(_txTitles[i],
                                        'Transaction Title')),
                                const SizedBox(width: 8),
                                Expanded(
                                    flex: 4,
                                    child: _formField(
                                        _txAmounts[i], 'Amount',
                                        isNumber: true)),
                                if (_txTitles.length > 1)
                                  GestureDetector(
                                    onTap: () => _removeRow(i),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.only(left: 6),
                                      child: Icon(Icons.close,
                                          size: 18,
                                          color: Color(0xFFC63A2B)),
                                    ),
                                  ),
                              ],
                            ),
                          )),

                  GestureDetector(
                    onTap: _addRow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.grey.shade300),
                      ),
                      child: const Text('Add more transactions',
                          style: TextStyle(
                              color: Color(0xFF1D3867),
                              fontSize: 13)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        
                        for (final c in _txTitles) c.clear();
                        for (final c in _txAmounts) c.clear();
                      }),
                      child: const Icon(Icons.delete_outline,
                          color: Color(0xFF1D3867), size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add to Spendings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D3867),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(
          color: Color(0xFF1D3867), fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFF1D3867)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}