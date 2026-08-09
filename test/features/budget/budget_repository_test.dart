import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/budget/data/budget_repository.dart';
import 'package:ascend/shared/models/budget_config.dart';
import 'package:ascend/shared/models/cost_item.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BudgetRepository repository;
  const uid = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = BudgetRepository(firestore: firestore);
  });

  test('watchBudget returns BudgetConfig.empty before anything is saved', () async {
    final config = await repository.watchBudget(uid).first;
    expect(config.monthlyIncome, 0);
    expect(config.fixedCosts, isEmpty);
    expect(config.variableCosts, isEmpty);
  });

  test('save persists income and cost lists, retrievable via watchBudget', () async {
    final config = BudgetConfig(
      monthlyIncome: 12000,
      fixedCosts: const [CostItem(id: 'rent', name: 'Rent', amount: 4000)],
      variableCosts: const [CostItem(id: 'groceries', name: 'Groceries', amount: 1500)],
    );
    await repository.save(uid, config);

    final loaded = await repository.watchBudget(uid).first;
    expect(loaded.monthlyIncome, 12000);
    expect(loaded.fixedCosts.single.name, 'Rent');
    expect(loaded.variableCosts.single.amount, 1500);
  });

  test('scopes budget to the given uid', () async {
    await repository.save(
      uid,
      const BudgetConfig(monthlyIncome: 5000, fixedCosts: [], variableCosts: []),
    );
    final other = await repository.watchBudget('other-user').first;
    expect(other.monthlyIncome, 0);
  });
}
