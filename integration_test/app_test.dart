// Integration test placeholder.
// Run with: flutter test integration_test/

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ase485_capstone_finance_ml/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full app smoke test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // TODO: Add full E2E flow tests
    expect(find.text('SmartSpend'), findsOneWidget);
  });
}
