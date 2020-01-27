Still in development and not stable.

v0.3 is not compatible with v0.2 and earlier.

# store_builder

Flux store and builder for Flutter.

## Install

See [pub.dartlang.org/packages/store_builder](https://pub.dartlang.org/packages/store_builder#-installing-tab-)

## Description

`store_builder` provides `Store`, `StoredSubject` and `StoreBuilder`.

`Store` represents the state of the entire app.
It can have multiple `StoredSubject`s internally.

`StoredSubject` is a single stream in `Store` that identified by type and id.

`StoreBuilder` is a `Widget` that bound with a `StoredSubject`
and rebuilt when the `StoredSubject` gets a new value.

## Usage

Create a `Store` to holds state of the your app.

### Store

```dart
final Store store = Store();
```

### StoreBuilder

Use `StoreBuilder<T>` to build widgets with a stream.
It is bound to `StoredSubject<T>` in the `Store` that identified by type and id.

```dart
child: StoreBuilder<int>(
  id: 'my_counter',
  builder: (BuildContext context, StoredSubject<int> subject) {
    if (subject.hasError) {
      return YourErrorWidget(value.error);
    } else if (!subject.hasValue) {
      return YourLoadingWidget();
    }
    return YourCounterWidget(subject.value);
  },
),
```

### StoredSubject

`StoredSubject` provides stream and sink for data that keeps updating.

`StoredSubject`s of the same type and id in the `Store` have a same stream
and sink. It allows to refer the same data from all over the app.

You can gets a `StoredSubject` from `Store` by `Store#use` method.

After using `StoredSubject`, you must to call `StoredSubject#release`
to tell `Store` of the end of use.

When a value is sent to `StoredSubject`,
all listeners observing the same `StoredSubject` are called.

`StoreBuilder`s are rebuilt because it observes `StoredSubject`
of the specified type and id.

```dart
// gets a subject.
final StoredSubject<int> subject = store.use<int>('counter');

// gets a value
final int counter = subject.value ?? 0;

// updates the value.
subject.value = counter + 1;
// subject.add(counter + 1)
```

## We are soliciting opinions

Which is better, `StoredSubject` or `SharedSubject`?

I am not good at English,
so if you found any mistakes in the documentation or comments,
please let me know.

