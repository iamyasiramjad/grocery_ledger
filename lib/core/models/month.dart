class Month {
  final int id;
  final int year;
  final int month;
  final double? budget;
  final DateTime createdAt;
  final DateTime finalizedAt;

  const Month({
    required this.id,
    required this.year,
    required this.month,
    this.budget,
    required this.createdAt,
    this.finalizedAt,
  });

  bool get isFinalized => finalizedAt != null;

  String get label {
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}