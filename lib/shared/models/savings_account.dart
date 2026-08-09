/// Whether a savings account's balance is spendable cash or money moved
/// into investments — drives the Momentum score's emergency-fund and
/// investment-ratio components, which treat the two very differently
/// (investments aren't instantly accessible, so they don't count as an
/// emergency fund).
enum AccountType {
  cash,
  investment;

  /// Stable Firestore value — decoupled from the Dart enum member name so
  /// a future rename can't silently change stored data.
  String get id => switch (this) {
        AccountType.cash => 'cash',
        AccountType.investment => 'investment',
      };

  static AccountType fromId(String id) => AccountType.values.firstWhere(
        (type) => type.id == id,
        orElse: () => throw ArgumentError('Unknown account type id: $id'),
      );

  String get label => switch (this) {
        AccountType.cash => 'Cash',
        AccountType.investment => 'Investment',
      };
}

/// A single savings account (e.g. "Emergency fund", "Brokerage") that
/// savings transactions can be tagged to via `AppTransaction.accountId`.
/// Its balance is derived live from those transactions rather than stored
/// here, matching how net worth itself is derived from the transaction
/// ledger rather than a stored total.
class SavingsAccount {
  const SavingsAccount({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final AccountType type;

  factory SavingsAccount.fromFirestore(String id, Map<String, dynamic> data) {
    return SavingsAccount(
      id: id,
      name: data['name'] as String,
      type: AccountType.fromId(data['type'] as String),
    );
  }

  Map<String, Object?> toFirestore() => {'name': name, 'type': type.id};

  SavingsAccount copyWith({String? name, AccountType? type}) {
    return SavingsAccount(id: id, name: name ?? this.name, type: type ?? this.type);
  }
}
