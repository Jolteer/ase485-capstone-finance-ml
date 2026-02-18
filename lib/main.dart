import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/app.dart';

/// Entry point of the SmartSpend application.
///
/// [WidgetsFlutterBinding.ensureInitialized] is called before [runApp] to
/// guarantee that the Flutter engine is ready before any async plugins or
/// platform channels are used (e.g. local storage, camera, etc.).
/// [SmartSpendApp] is the root widget defined in app.dart.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartSpendApp());
}
