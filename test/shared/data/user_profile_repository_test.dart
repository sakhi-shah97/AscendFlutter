import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/shared/data/user_profile_repository.dart';

void main() {
  test('watchProfile returns null when no profile document exists', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = UserProfileRepository(firestore: firestore);
    expect(await repository.watchProfile('user-1').first, isNull);
  });

  test('watchProfile parses an existing profile document', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('user-1').set({
      'email': 'a@b.com',
      'displayName': 'Ada',
      'currency': 'USD',
    });

    final repository = UserProfileRepository(firestore: firestore);
    final profile = await repository.watchProfile('user-1').first;
    expect(profile?.email, 'a@b.com');
    expect(profile?.currency, 'USD');
  });

  test('updateCurrency changes only the currency field', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('user-1').set({
      'email': 'a@b.com',
      'currency': 'AED',
    });
    final repository = UserProfileRepository(firestore: firestore);

    await repository.updateCurrency('user-1', 'USD');

    final profile = await repository.watchProfile('user-1').first;
    expect(profile?.currency, 'USD');
    expect(profile?.email, 'a@b.com');
  });
}
