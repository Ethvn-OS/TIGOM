import 'package:flutter/material.dart';

class SpendingsCard extends StatelessWidget {
  const SpendingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _Category('Food', 33, const Color(0xFF1D3867)),
      _Category('Transport', 23, const Color(0xFFe4be74)),
      _Category('Bills', 17, const Color(0xFF6B4FA0)),
      _Category('Shopping', 14, const Color(0xFFE2520B)),
      _Category('Leisure', 12, const Color(0xFF4CAF50)),
    ];

    final transactions = [
      _Transaction('Jollibee', 'Food', 250, 'Today, 1:14 PM', Icons.fastfood),
      _Transaction('Grab', 'Transport', 180, 'Today, 10:32 AM', Icons.directions_car),
      _Transaction('Netflix', 'Leisure', 549, 'May 8', Icons.tv),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE7BA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Date header
          

          // Spendings summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spendings this month',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1D3867)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '₱9,820',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3867),
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.arrow_upward,
                                size: 14, color: Color(0xFF4CAF50)),
                            SizedBox(width: 2),
                            Text(
                              '12.4% from last month',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '9,820 / 15,000 budget',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF1D3867)),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 9820 / 15000,
                              minHeight: 6,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(
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
                            painter: _DonutPainter(categories),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '65%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D3867),
                                ),
                              ),
                              Text(
                                'of budget',
                                style: TextStyle(
                                    fontSize: 9, color: Color(0xFF1D3867)),
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
                  children: categories.map((c) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${c.name} ${c.percent}%',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF1D3867)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFe4be74),
          ),

          // Recent Transactions header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
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
          ...transactions.map((t) => _TransactionTile(transaction: t)),

          // Footer
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9E9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '9 transactions this month',
                  style:
                      TextStyle(fontSize: 12, color: Color(0xFF1D3867)),
                ),
                Row(
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

class _TransactionTile extends StatelessWidget {
  final _Transaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              color: const Color(0xFFe4be74).withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(transaction.icon,
                size: 20, color: const Color(0xFF1D3867)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D3867),
                  ),
                ),
                Text(
                  transaction.category,
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
                '-₱${transaction.amount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3867),
                ),
              ),
              Text(
                transaction.time,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String name;
  final int percent;
  final Color color;
  _Category(this.name, this.percent, this.color);
}

class _Transaction {
  final String name;
  final String category;
  final double amount;
  final String time;
  final IconData icon;
  _Transaction(
      this.name, this.category, this.amount, this.time, this.icon);
}

class _DonutPainter extends CustomPainter {
  final List<_Category> categories;
  _DonutPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -3.14 / 2;
    const strokeWidth = 12.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (final cat in categories) {
      final sweepAngle = (cat.percent / 100) * 2 * 3.14159;
      paint.color = cat.color;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) => false;
}