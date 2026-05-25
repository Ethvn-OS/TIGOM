class TransactionItem {
  String title;
  double amount;

  TransactionItem({required this.title, required this.amount});
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