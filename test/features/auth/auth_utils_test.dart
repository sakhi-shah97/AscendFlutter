import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/features/auth/presentation/auth_utils.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty input', () => expect(validateEmail(''), isNotNull));
    test('rejects null', () => expect(validateEmail(null), isNotNull));
    test('rejects missing @', () => expect(validateEmail('foo.com'), isNotNull));
    test('rejects missing domain dot', () => expect(validateEmail('foo@bar'), isNotNull));
    test('accepts a valid email', () => expect(validateEmail('foo@bar.com'), isNull));
  });

  group('validatePassword', () {
    test('rejects empty input', () => expect(validatePassword(''), isNotNull));
    test('rejects null', () => expect(validatePassword(null), isNotNull));
    test('rejects fewer than 6 characters', () => expect(validatePassword('abc12'), isNotNull));
    test('accepts 6 or more characters', () => expect(validatePassword('abc123'), isNull));
  });

  group('authErrorMessage', () {
    test('maps email-already-in-use', () {
      expect(
        authErrorMessage(Exception('email-already-in-use')),
        contains('already exists'),
      );
    });

    test('maps wrong-password / invalid-credential / user-not-found', () {
      expect(authErrorMessage(Exception('wrong-password')), contains('Incorrect'));
      expect(authErrorMessage(Exception('invalid-credential')), contains('Incorrect'));
      expect(authErrorMessage(Exception('user-not-found')), contains('Incorrect'));
    });

    test('maps too-many-requests', () {
      expect(authErrorMessage(Exception('too-many-requests')), contains('Too many'));
    });

    test('maps network-request-failed', () {
      expect(authErrorMessage(Exception('network-request-failed')), contains('Network'));
    });

    test('falls back to a generic message for unknown errors', () {
      expect(
        authErrorMessage(Exception('some-unrecognized-code')),
        'Something went wrong. Please try again.',
      );
    });
  });
}
