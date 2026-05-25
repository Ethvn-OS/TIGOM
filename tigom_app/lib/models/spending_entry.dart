class TransactionItem {
  String? transactionId;
  String title;
  double amount;
  String? categoryId;

  TransactionItem({
    this.transactionId,
    required this.title,
    required this.amount,
    this.categoryId,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      transactionId: map['transaction_id'] as String?,
      title: map['description'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      categoryId: map['category_id'] as String?,
    );
  }
}

class SpendingEntry {
  String title;
  List<TransactionItem> transactions;
  DateTime createdAt;

  SpendingEntry({
    required this.title,
    required this.transactions,
    required this.createdAt,
  });

  double get total => transactions.fold(0, (sum, t) => sum + t.amount);
}