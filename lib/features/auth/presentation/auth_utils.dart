String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter your email.';
  if (!value.contains('@') || !value.contains('.')) {
    return 'Enter a valid email.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter your password.';
  if (value.length < 6) return 'Password must be at least 6 characters.';
  return null;
}

String authErrorMessage(Object error) {
  final message = error.toString();
  if (message.contains('email-already-in-use')) {
    return 'An account already exists with that email.';
  }
  if (message.contains('invalid-credential') ||
      message.contains('wrong-password') ||
      message.contains('user-not-found')) {
    return 'Incorrect email or password.';
  }
  if (message.contains('too-many-requests')) {
    return 'Too many attempts. Try again later.';
  }
  if (message.contains('network-request-failed')) {
    return 'Network error. Check your connection.';
  }
  return 'Something went wrong. Please try again.';
}
