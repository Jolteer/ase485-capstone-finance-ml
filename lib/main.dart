/// App entry point: ensures Flutter bindings and runs [SmartSpendApp].
///
/// Called by the Dart/Flutter runtime; do not invoke manually.
library;
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/app.dart';

/// Initializes Flutter bindings and launches the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartSpendApp());
}
