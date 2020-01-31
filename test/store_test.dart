import 'package:flutter_test/flutter_test.dart';

import 'package:store_builder/store_builder.dart';

void main() {
  test("Non-seeded subject has null value", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter");

    expect(subject1.value, isNull);
    expect(subject1.hasValue, isFalse);
    expect(subject1.error, isNull);
    expect(subject1.hasError, isFalse);

    subject1.release();
  });

  test("Seeded subject has non-null value", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter", seedValue: 1);

    expect(subject1.value, 1);
    expect(subject1.hasValue, isTrue);
    expect(subject1.error, isNull);
    expect(subject1.hasError, isFalse);

    subject1.release();
  });

  test("Same id returns same subject", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter");
    final StoredSubject<int> subject2 = store.use<int>("counter");

    expect(identical(subject1, subject2), isTrue);

    subject1.release();
    subject2.release();
  });

  test("Different id returns different subjects", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("foo");
    final StoredSubject<int> subject2 = store.use<int>("bar");

    expect(identical(subject1, subject2), isFalse);

    const int value1 = 123;
    subject1.value = value1;
    expect(subject1.value, value1);
    expect(subject2.value, isNull);

    subject1.release();
    subject2.release();
  });

  test("Adding values to subject", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter");
    final StoredSubject<int> subject2 = store.use<int>("counter");

    const int value1 = 123;
    subject1.value = value1;

    expect(subject1.value, value1);
    expect(subject2.value, value1);

    const int value2 = 456;
    subject1.value = value2;

    expect(subject1.value, value2);
    expect(subject2.value, value2);

    subject1.release();
    subject2.release();
  });

  test("Listen to subject", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter");

    int count = 1;
    subject1.listen(expectAsync1(
      (i) {
        expect(i, count);
        count++;
      },
      count: 3,
    ));

    subject1.value = 1;
    subject1.value = 2;
    subject1.value = 3;

    subject1.release();
  });

  test("Released subject is no longer in the store", () {
    final Store store = Store();
    final StoredSubject<int> subject1 = store.use<int>("counter");

    subject1.value = 123;
    expect(subject1.value, 123);

    subject1.release();

    final StoredSubject<int> subject2 = store.use<int>("counter");

    expect(identical(subject1, subject2), isFalse);

    expect(subject2.value, isNull);
    expect(subject2.hasValue, isFalse);
    expect(subject2.error, isNull);
    expect(subject2.hasError, isFalse);

    subject2.release();
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
