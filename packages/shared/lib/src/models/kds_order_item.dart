class KdsOrderItem {
  final String name;
  final int qty;
  final String notes;

  const KdsOrderItem({
    required this.name,
    required this.qty,
    required this.notes,
  });

  factory KdsOrderItem.fromMap(Map<String, dynamic> map) {
    return KdsOrderItem(
      name: (map['name'] as String?) ?? '',
      qty: (map['qty'] as int?) ?? 1,
      notes: (map['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'notes': notes,
      };
}
