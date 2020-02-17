import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

import 'package:store_builder/store_builder.dart';

void main() {
  testWidgets("SubjectProvider is built with subject", (tester) async {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter", seedValue: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: SubjectProvider<int>(
          store: store,
          id: "counter",
          child: Consumer<int>(
            builder: (BuildContext context, int value, Widget child) {
              return Text('${value}');
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    subject1.value = 1;
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
