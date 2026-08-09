import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/utils/currency.dart';

void main() {
  group('formatCurrency', () {
    test('formats AED with its symbol and thousands separators', () {
      expect(formatCurrency(1234.5, 'AED'), 'AED 1,234.50');
    });

    test('formats USD with a dollar sign', () {
      expect(formatCurrency(99, 'USD'), '\$99.00');
    });

    test('falls back to the code itself for unmapped currencies', () {
      expect(formatCurrency(10, 'XYZ'), 'XYZ 10.00');
    });

    test('formats zero', () {
      expect(formatCurrency(0, 'AED'), 'AED 0.00');
    });
  });
}
