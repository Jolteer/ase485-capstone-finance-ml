import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/app.dart';

/// Application entry point.
/// 
/// Initializes Flutter bindings and launches the [SmartSpendApp].
void main() {
  // Ensures Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Launch the application
  runApp(const SmartSpendApp());
}
