import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:store_builder/store_builder.dart';

void main() {
  testWidgets("SubjectBuilder is built with subject", (tester) async {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter", seedValue: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: SubjectBuilder<int>(
          store: store,
          id: "counter",
          builder: (BuildContext context, StoredSubject<int> subject) {
            return Text('${subject.value}');
          },
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


//  test("Adding errors to subject", () {
//    final Store store = Store();
//    final StoredSubject<int> subject1 = store.use<int>("counter");
//
//    subject1.value = 123;
//
//    expect(subject1.error, isNull);
//    expect(subject1.hasError, isFalse);
//
//    subject1.error = Exception("test error");
//
//    expect(subject1.error, isException);
//    expect(subject1.hasError, isTrue);
//
//    subject1.value = 456;
//
//    expect(subject1.error, isNull);
//    expect(subject1.hasError, isFalse);
//
//    subject1.release();
//  });
}
