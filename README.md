# store_builder

Flux store and builder for Flutter.

Version: 0.2.0

## Install

See [pub.dartlang.org/packages/store_builder](https://pub.dartlang.org/packages/store_builder#-installing-tab-)

## Usage

Add `StoreProvider` to your app. `Store` represents the state of the entire
app.

```dart
void main() => runApp(MaterialApp(
      title: 'Your app',
      home: StoreProvider(
        store: Store(),
        child: MyHomePage(),
      ),
    ));
```

Use `StoreBuilder<V>` to build widgets with the value. Bind to individual
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

You can gets the value from `Store` by `Store#get`, or update it by
`Store#set`.

When a value is updates by `Store#set`, all `StoreBuilder`s associated with
that name are rebuilt.

For separation of responsibility, we recommend that you implement store
operations independently as `Action`s.

```dart
class IncrementCounterAction implements Action {
  Future<void> run(Store store) async {
    final int counter = store.get<int>("counter").value ?? 0;
    store.set<int>("counter", counter + 1);
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
