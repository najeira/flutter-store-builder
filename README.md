# store_builder

Flux store and builder for Flutter.

## Install

See [pub.dartlang.org/packages/store_builder](https://pub.dartlang.org/packages/store_builder#-installing-tab-)

## Description

`store_builder` provides `Store`, `Value` and `StoreBuilder`.

`Store` represents the state of the entire app. It can have multiple `Value`s.

`Value` is a single value in the `Store` that identified by name.

`StoreBuilder` is a `Widget` that bind with a `Value` and rebuilt when the
`Value` is updated.

## Usage

Add `StoreProvider` and `Store` to your app. It makes your widgets allows to
access the `Store`.

```dart
void main() => runApp(MaterialApp(
      title: 'Your app',
      home: StoreProvider(
        store: Store(),
        child: MyHomePage(),
      ),
    ));
```

Use `StoreBuilder<V>` to build widgets with a value. It is bind to individual
values in the `Store` by name.

```dart
child: StoreBuilder<int>(
  name: "counter",
  builder: (BuildContext context, Value<int> value) {
    if (value.error != null) {
        return ErrorWidget(value.error);
    } else if (value.value == null) {
        return LoadingWidget();
    }
    return YourWidget(value.value);
  },
),
```

You can gets a `Value` from `Store` by `Store#value` method, and gets the value
by `Value#value` property.

```dart
// gets a Value.
final Value<int> value = store.value<int>("counter");

// Value has value and error.
final int counter = value.value ?? 0;
// final Object error = value.error;

// Update the value.
value.value = counter + 1;
```

When a `Value` is updates by `Value#value` and `Value#error`, all
`StoreBuilder`s associated with that name are rebuilt.

For separation of responsibility, we recommend that you implement store
operations independently as `Action`s.

```dart
class Names {
  static const String counter = 'counter';
  
  ...
  
}

class Values {
  static Value<int> counter(Store store)
      => store.value<int>(Names.counter);
  
  ...
  
}

class IncrementCounterAction implements Action {
  Future<void> run(Store store) async {
    final Value<int> value = Values.counter(store);
    final int counter = value.value ?? 0;
    value.value = counter + 1;
  }
}
```

And widgets calls the action.

```dart
class YourWidget extends StatelessWidget {
  
  ...
  
  void incrementCounter() {
    Store.of(context).action(IncrementCounterAction());
  }
}
```
