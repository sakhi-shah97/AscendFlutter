import 'package:intl/intl.dart';

/// Reasonable default currency choices for the Settings selector and the
/// first-run prompt. Not exhaustive — any other ISO 4217 code still
/// formats fine via the generic "CODE " fallback below.
const supportedCurrencies = <String>[
  'AED', 'USD', 'EUR', 'GBP', 'INR', 'SAR', 'PKR', 'CAD', 'AUD', 'JPY',
];

const _currencySymbols = <String, String>{
  'AED': 'AED ',
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'INR': '₹',
  'SAR': 'SAR ',
  'PKR': 'Rs ',
  'CAD': 'CA\$',
  'AUD': 'A\$',
  'JPY': '¥',
};

/// Formats a non-negative magnitude with the given ISO 4217 [currencyCode]
/// (e.g. `formatCurrency(1234.5, 'AED')` → `"AED 1,234.50"`). Callers add
/// any +/− sign themselves, since [amount] is generally a stored-positive
/// transaction value.
String formatCurrency(double amount, String currencyCode) {
  final symbol = _currencySymbols[currencyCode] ?? '$currencyCode ';
  return '$symbol${NumberFormat('#,##0.00').format(amount)}';
}
