/// A single named line in the fixed or variable costs list. [amount] is a
/// fixed monthly cost for fixed costs, or a monthly budget cap for variable
/// costs — the two lists share this shape since both are just "name +
/// AED figure" rows the user edits.
class CostItem {
  const CostItem({required this.id, required this.name, required this.amount});

  final String id;
  final String name;
  final double amount;

  factory CostItem.fromMap(Map<String, dynamic> map) {
    return CostItem(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() => {'id': id, 'name': name, 'amount': amount};

  CostItem copyWith({String? name, double? amount}) {
    return CostItem(id: id, name: name ?? this.name, amount: amount ?? this.amount);
  }
}
