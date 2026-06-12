import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reap/app.dart';

void main() {
  testWidgets('REAP app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReapApp(),
      ),
    );

    // Verify the app starts
    expect(find.text('REAP'), findsOneWidget);
  });
}
