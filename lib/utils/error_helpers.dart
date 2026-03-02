/// Strips the Dart 'Exception: ' prefix from error messages.
///
/// Use in providers to store clean, user-friendly error text.
String formatError(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
