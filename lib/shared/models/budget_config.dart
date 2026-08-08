import 'cost_item.dart';

class BudgetConfig {
  const BudgetConfig({
    required this.monthlyIncome,
    required this.fixedCosts,
    required this.variableCosts,
  });

  static const empty = BudgetConfig(monthlyIncome: 0, fixedCosts: [], variableCosts: []);

  final double monthlyIncome;
  final List<CostItem> fixedCosts;
  final List<CostItem> variableCosts;

  double get fixedCostsTotal => fixedCosts.fold(0, (sum, item) => sum + item.amount);
  double get variableBudgetTotal => variableCosts.fold(0, (sum, item) => sum + item.amount);

  factory BudgetConfig.fromFirestore(Map<String, dynamic> data) {
    return BudgetConfig(
      monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble() ?? 0,
      fixedCosts: (data['fixedCosts'] as List<dynamic>? ?? [])
          .map((item) => CostItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      variableCosts: (data['variableCosts'] as List<dynamic>? ?? [])
          .map((item) => CostItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'monthlyIncome': monthlyIncome,
      'fixedCosts': fixedCosts.map((item) => item.toMap()).toList(),
      'variableCosts': variableCosts.map((item) => item.toMap()).toList(),
    };
  }

  BudgetConfig copyWith({
    double? monthlyIncome,
    List<CostItem>? fixedCosts,
    List<CostItem>? variableCosts,
  }) {
    return BudgetConfig(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      fixedCosts: fixedCosts ?? this.fixedCosts,
      variableCosts: variableCosts ?? this.variableCosts,
    );
  }
}
