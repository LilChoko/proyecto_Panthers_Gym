class Sale {
  final int id;
  final DateTime date;
  final String status;
  final double totalPrice;
  final DateTime reminderDate;

  Sale({
    required this.id,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.reminderDate,
  });
}
