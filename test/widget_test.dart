import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/auth/presentation/sign_in_screen.dart';

void main() {
  testWidgets('Sign-in screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const SignInScreen(),
        ),
      ),
    );
    expect(find.text('Ascend'), findsOneWidget);
  });
}
