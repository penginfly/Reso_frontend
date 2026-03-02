// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Root shell renders bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TrapizzinoApp());

    expect(find.byType(CNTabBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
