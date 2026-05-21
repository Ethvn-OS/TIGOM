import 'package:flutter/material.dart';
import 'package:tigom_app/services/supabase_service.dart';
import 'dart:math';

class SpendingsCard extends StatefulWidget {
  const SpendingsCard({super.key});

  @override
  State<SpendingsCard> createState() => _SpendingsCardState();
}

class _SpendingsCardState extends State<SpendingsCard> {
  bool loading = true;
  double totalSpending = 0;
  double lastMonthSpending = 0;
  List<Map<String, dynamic>> recentTransactions = [];
  Map<String, double> categoryTotals = {};
  int totalCount = 0;

  final List<Color> categoryColors = const [
    Color(0xFF1D3867),
    Color(0xFFe4be74),
    Color(0xFF6B4FA0),
    Color(0xFFE2520B),
    Color(0xFF4CAF50),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final spending = await SupabaseService.getMonthlySpending();
      final recent = await SupabaseService.getRecentTransactions();
      final all = await SupabaseService.getTransactions();

      // category totals
      final Map<String, double> cats = {};
      int count = 0;
      for (final t in all) {
        if (t['type'] == 'expense') {
          final name = t['categories']?['name'] as String? ?? 'Other';
          cats[name] = (cats[name] ?? 0) + (t['amount'] as num).toDouble();
          count++;
        }
      }

      // last month spending
      final now = DateTime.now();
      final firstOfLastMonth = DateTime(now.year, now.month - 1, 1).toIso8601String();
      final firstOfThisMonth = DateTime(now.year, now.month, 1).toIso8601String();
      double lastMonth = 0;
      for (final t in all) {
        if (t['type'] == 'expense') {
          final date = t['transaction_date'] as String? ?? '';
          if (date.compareTo(firstOfLastMonth) >= 0 &&
              date.compareTo(firstOfThisMonth) < 0) {
            lastMonth += (t['amount'] as num).toDouble();
          }
        }
      }

      setState(() {
        totalSpending = spending;
        recentTransactions = recent;
        categoryTotals = cats;
        totalCount = count;
        lastMonthSpending = lastMonth;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final withCommas = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$withCommas.${parts[1]}';
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final min = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return 'Today, $hour:$min $period';
    }
    return '${_monthName(date.month)} ${date.day}';
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }

  IconData _iconForCategory(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'food': return Icons.fastfood;
      case 'transport': return Icons.directions_car;
      case 'bills': return Icons.receipt_long;
      case 'shopping': return Icons.shopping_bag;
      case 'leisure': return Icons.tv;
      default: return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryTotals.entries.toList();
    final grandTotal = categoryTotals.values.fold(0.0, (a, b) => a + b);
    const double budget = 15000;

    // % change from last month
    double percentChange = 0;
    if (lastMonthSpending > 0) {
      percentChange =
          ((totalSpending - lastMonthSpending) / lastMonthSpending) * 100;
    }
    final isUp = percentChange >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE7BA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1D3867)),
              ),
            )
          : Column(
              children: [
                // Date header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9E9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: Color(0xFF1D3867)),
                        const SizedBox(width: 6),
                        const Text('Current date',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF1D3867))),
                        const SizedBox(width: 4),
                        Text(
                          '${_monthName(DateTime.now().month)} ${DateTime.now().day}, ${DateTime.now().year}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D3867)),
                        ),
                      ]),
                      Row(children: [
                        const Icon(Icons.flag_outlined,
                            size: 14, color: Color(0xFF1D3867)),
                        const SizedBox(width: 4),
                        const Text('Goal',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF1D3867))),
                        const SizedBox(width: 4),
                        const Text('Dec 31, 2026',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D3867))),
                      ]),
                    ],
                  ),
                ),

                // Spendings summary
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spendings this month',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF1D3867)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₱${formatMoney(totalSpending)}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D3867),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    isUp
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 14,
                                    color: isUp
                                        ? const Color(0xFF4CAF50)
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${percentChange.abs().toStringAsFixed(1)}% from last month',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isUp
                                          ? const Color(0xFF4CAF50)
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${formatMoney(totalSpending)} / ${formatMoney(budget)} budget',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1D3867)),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (totalSpending / budget)
                                        .clamp(0, 1),
                                    minHeight: 6,
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF1D3867)),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Donut chart
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(90, 90),
                                  painter: _DonutPainter(
                                    categories.isEmpty
                                        ? [
                                            _Slice(1.0,
                                                Colors.grey.shade300)
                                          ]
                                        : categories
                                            .asMap()
                                            .entries
                                            .map((e) => _Slice(
                                                  grandTotal > 0
                                                      ? e.value.value /
                                                          grandTotal
                                                      : 0,
                                                  categoryColors[e.key %
                                                      categoryColors
                                                          .length],
                                                ))
                                            .toList(),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${((totalSpending / budget) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D3867),
                                      ),
                                    ),
                                    const Text(
                                      'of budget',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF1D3867)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Legend
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: categories.asMap().entries.map((e) {
                          final pct = grandTotal > 0
                              ? (e.value.value / grandTotal * 100)
                                  .toStringAsFixed(0)
                              : '0';
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: categoryColors[e.key %
                                      categoryColors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${e.value.key} $pct%',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1D3867)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(height: 1, color: const Color(0xFFe4be74)),

                // Recent Transactions header
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'RECENT TRANSACTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF1D3867),
                      ),
                    ),
                  ),
                ),

                // Transactions list
                if (recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: Color(0xFF1D3867)),
                    ),
                  )
                else
                  ...recentTransactions.map((t) {
                    final catName =
                        t['categories']?['name'] as String? ?? 'Other';
                    final amount =
                        (t['amount'] as num).toDouble();
                    final date =
                        formatDate(t['transaction_date'] as String?);
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFe4be74)
                                  .withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _iconForCategory(catName),
                              size: 20,
                              color: const Color(0xFF1D3867),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['description'] as String? ?? catName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1D3867),
                                  ),
                                ),
                                Text(
                                  catName,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '-₱${formatMoney(amount)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D3867),
                                ),
                              ),
                              Text(
                                date,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                // Footer
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9E9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalCount transactions this month',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF1D3867)),
                      ),
                      const Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D3867),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right,
                              size: 16, color: Color(0xFF1D3867)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Slice {
  final double value;
  final Color color;
  _Slice(this.value, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  _DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -pi / 2;
    const strokeWidth = 12.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (final s in slices) {
      final sweepAngle = s.value * 2 * pi;
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height)
            .deflate(strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.slices != slices;
}