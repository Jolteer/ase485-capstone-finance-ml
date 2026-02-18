/// Canonical list of spending categories used throughout the app.
///
/// These strings are shared between the UI (dropdown menus, filter chips),
/// the API request payloads, and the ML categorisation model. Keeping them
/// in one place avoids typos and makes it easy to add/remove categories.
class Categories {
  /// Private constructor prevents instantiation.
  Categories._();

  // ---- individual category constants ----

  static const String food = 'Food';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills';
  static const String shopping = 'Shopping';
  static const String transportation = 'Transportation';
  static const String healthcare = 'Healthcare';
  static const String education = 'Education';
  static const String other = 'Other';

  /// All categories in display order. Used to populate dropdowns and
  /// to assign colours from [AppColors.categoryPalette].
  static const List<String> all = [
    food,
    entertainment,
    bills,
    shopping,
    transportation,
    healthcare,
    education,
    other,
  ];
}
