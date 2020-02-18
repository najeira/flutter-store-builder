Still in development and not stable.

v0.4 is not compatible with v0.3 and earlier.

# store_builder

A Flux store that aggregates the state of the app
and various widgets that use it.

## Install

See [pub.dartlang.org/packages/store_builder](https://pub.dartlang.org/packages/store_builder#-installing-tab-)

## Description

`store_builder` provides `Store` and `StoredSubject` for state,
And `StoreProvider`, `SubjectBuilder` and `SubjectProvider` for widgets.

`Store` represents the state of the entire app.
It can have multiple `StoredSubject`s internally.

`StoredSubject` is a single stream in `Store` that identified by type and id.

`SubjectBuilder` is a widget that bound with a `StoredSubject`
and rebuilt when the `StoredSubject` gets a new value.

`SubjectProvider` is a widget that provides a `StoredSubject`
and its value to descendants.

## Usage

### Store and StoreProvider

Create a `Store` to holds the state of the app.

Generally, provide the `Store` for wigets tree at the root of the app.
You can use `StoreProvider` for that.

```dart
StoreProvider(
  store: Store(),
  child: MaterialApp(...),
);
```

### SubjectBuilder

Use `SubjectBuilder<T>` to build widgets with a subject.

It is bound to `StoredSubject<T>` in the `Store` that identified by type and id.

```dart
child: SubjectBuilder<int>(
  id: 'my counter',
  builder: (BuildContext context, StoredSubject<int> subject, Widget child) {
    if (subject.hasError) {
      return YourErrorWidget(value.error);
    } else if (!subject.hasValue) {
      return YourLoadingWidget();
    }
    return YourCounterWidget(subject.value);
  },
),
```

### SubjectProvider

Use `SubjectProvider<T>` to provide the subject and its value to descendants.

It is bound to `StoredSubject<T>` in the `Store` that identified by type and id.

The difference from `SubjectBuilder` is that `SubjectProvider` and
consumers can be described separately in the widget tree.

```dart
SubjectProvider<int>(
  id: 'my counter',
  child: Consumer<StoredSubject<int>>(
    builder: (BuildContext context, StoredSubject<int> subject, Widget child) {
      if (subject.hasError) {
        return ErrorWidget(subject.error);
      } else if (!subject.hasValue) {
        return YourLoadingWidget();
      }
      return YourCounterWidget(subject.value);
    },
  ),
);
```

### StoredSubject

`StoredSubject` provides stream and sink for data that keeps updating.

`StoredSubject`s of the same type and id in the `Store` have the same stream
and sink. It allows to refer the same data from all over the app.

You can get a `StoredSubject` from `Store` by `Store#use` method.

After using `StoredSubject`, you must call `StoredSubject#release`
to tell `Store` of the end of use.

`SubjectBuilder` and `SubjectProvider` call `StoredSubject#release` properly
internally, depending on the lifetime of the widget.

When a new value is sent to `StoredSubject`,
all listeners observing the `StoredSubject` are called.

That is, the related `SubjectBuilder`s are also rebuilt.

```dart
// gets a subject.
final StoredSubject<int> subject = store.use<int>('counter');

// gets a value
final int counter = subject.value ?? 0;

// updates the value.
subject.value = counter + 1;

subject.release();
```

## Data lifetime

Data is kept in `Store` as long as there are `StoredSubject`s used.

When all `StoredSubject`s with the same type and id are released,
they are removed from `Store`.

In other words, data management by reference counting.

`SubjectBuilder` and `SubjectProvider` uses `StoredSubject` internally,
so `StoredSubject` will be kept as long as there is a related their widgets.

If you want to keep the data even if widgets are gone,
get `StoredSubject` and do not release it.

## We are soliciting opinions

Do you have a suggestion for a more appropriate class name?

I am not good at English,
so if you found any mistakes in the documentation or comments,
please let me know.
