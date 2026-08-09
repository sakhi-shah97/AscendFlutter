import 'package:cloud_firestore/cloud_firestore.dart';

import 'transaction_type.dart';

/// A single ledger entry. Named `AppTransaction` (not `Transaction`) to
/// avoid colliding with `cloud_firestore`'s `Transaction` class.
class AppTransaction {
  const AppTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.category,
    this.note,
    this.accountId,
  }) : assert(amount >= 0, 'amount is always stored positive; sign comes from type');

  final String id;
  final TransactionType type;

  /// Always positive — [TransactionType.isIncrease] carries the sign.
  final double amount;
  final DateTime date;
  final String? category;
  final String? note;

  /// Which [SavingsAccount] this belongs to — only meaningful when
  /// [type]'s kind is [TransactionKind.savings]; null for every other
  /// kind, and for savings transactions predating the accounts feature
  /// until the one-time migration backfills it.
  final String? accountId;

  factory AppTransaction.fromFirestore(String id, Map<String, dynamic> data) {
    final dateValue = data['date'];
    return AppTransaction(
      id: id,
      type: TransactionType.fromId(data['type'] as String),
      amount: (data['amount'] as num).toDouble(),
      date: dateValue is Timestamp ? dateValue.toDate() : DateTime.now(),
      category: data['category'] as String?,
      note: data['note'] as String?,
      accountId: data['accountId'] as String?,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'type': type.id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'note': note,
      'accountId': accountId,
    };
  }

  AppTransaction copyWith({
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
    String? accountId,
  }) {
    return AppTransaction(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
    );
  }
}
