
class Transaction {
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Transaction({
    required this.title,
    this.description = '',
    required this.amount,
    this.category = '',
    required this.date,
  });
}


