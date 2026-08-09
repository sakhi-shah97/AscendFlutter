import 'cost_item.dart';

class BudgetConfig {
  const BudgetConfig({
    required this.monthlyIncome,
    required this.fixedCosts,
    required this.variableCosts,
  });

  static const empty = BudgetConfig(monthlyIncome: 0, fixedCosts: [], variableCosts: []);

  /// Sensible, globally-applicable starter categories seeded for brand-new
  /// users so Budget isn't empty on day one. Amounts start at 0 — there's
  /// no way to know a new user's real figures, so they fill those in
  /// themselves; the categories are the head start.
  static const defaultSeed = BudgetConfig(
    monthlyIncome: 0,
    fixedCosts: [
      CostItem(id: 'seed-rent', name: 'Rent', amount: 0),
      CostItem(id: 'seed-utilities', name: 'Utilities', amount: 0),
      CostItem(id: 'seed-insurance', name: 'Insurance', amount: 0),
      CostItem(id: 'seed-subscriptions', name: 'Subscriptions', amount: 0),
    ],
    variableCosts: [
      CostItem(id: 'seed-groceries', name: 'Groceries', amount: 0),
      CostItem(id: 'seed-transport', name: 'Transport', amount: 0),
      CostItem(id: 'seed-dining', name: 'Dining out', amount: 0),
      CostItem(id: 'seed-entertainment', name: 'Entertainment', amount: 0),
    ],
  );

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
