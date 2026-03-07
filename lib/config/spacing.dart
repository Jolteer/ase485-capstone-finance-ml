/// App-wide spacing scale for [SizedBox], [EdgeInsets], and gap values.
///
/// Use these named constants instead of inline pixel literals so that
/// every gap/padding in the app can be found and changed in one place.
/// Import this file wherever layout spacing is needed.
library;

/// Static spacing constants for the app. Do not instantiate.
class AppSpacing {
  AppSpacing._();

  /// 2 px — micro gaps (e.g. title-to-value in summary cards).
  static const double xxs = 2;

  /// 4 px — tight gaps (e.g. icon-to-subtitle, tiny visual separators).
  static const double xs = 4;

  /// 6 px — minor visual gaps (e.g. quick-action icon-to-label).
  static const double s6 = 6;

  /// 8 px — small gaps (e.g. row separators, list item padding).
  static const double sm = 8;

  /// 10 px — card-bottom margins and fine list separation.
  static const double s10 = 10;

  /// 12 px — medium gaps (e.g. grid gutters, card internal rows).
  static const double s12 = 12;

  /// 14 px — card inner padding.
  static const double s14 = 14;

  /// 16 px — standard content padding (most screens and cards).
  static const double md = 16;

  /// 20 px — section separator gaps.
  static const double s20 = 20;

  /// 24 px — large section padding.
  static const double lg = 24;

  /// 32 px — hero / extra-large screen-edge padding.
  static const double xl = 32;
}
