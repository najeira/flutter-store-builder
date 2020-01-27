import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:counter/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      title: '',
      home: MyHomePage(),
    ));
    await tester.pump();
    await tester.pump();

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
