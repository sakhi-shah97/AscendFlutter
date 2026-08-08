import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Net Financial Level (total savings − total debt), in AED.
///
/// Placeholder until the Budget/Accounts features exist to compute a real
/// balance from Firestore data — kept as its own provider (rather than
/// inlined in [HomeScreen]) so that seam is a one-line swap later, and so
/// tests can override it directly.
final netWorthProvider = Provider<double>((ref) => 0);
