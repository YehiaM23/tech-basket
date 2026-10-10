import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Cart updates and survives a restart', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Tech Basket'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Anker');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Add to cart'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(r'Total: $29.00'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(r'Total: $29.00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(r'Total: $29.00'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(r'Total: $29.00'), findsOneWidget);
  });
}
