/// Helpers for turning thrown errors into user-facing messages.
///
/// Used by providers (e.g. [AuthProvider], [BudgetProvider]) when catching API
/// or validation errors. Strips the Dart 'Exception: ' prefix from [error] for
/// cleaner display in snackbars or dialogs.
///
/// Returns the error message string suitable for [SnackBar] or [AlertDialog].
library;
String formatError(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
