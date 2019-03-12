# store_builder

Flux store and builder for Flutter.

## Usage

Add `StoreProvider` to your app.

```dart
void main() => runApp(MaterialApp(
      title: 'Your app',
      home: StoreProvider(
        store: Store(),
        child: MyHomePage(),
      ),
    ));
```

Use `StoreBuilder<V>` to build your widgets with the value.

```dart
child: StoreBuilder<int>(
  name: "counter",
  builder: (BuildContext context, Value<int> value) {
    return Text('${value.value}');
  },
),
```

Update state by `Store#set`, then your StoreBuilder will be rebuild.

```dart
class _IncrementCounterAction implements Action {
  Future<void> run(Store store) async {
    final int counter = store.get<int>("counter");
    store.set<int>("counter", counter + 1);
  }
}
```

```dart
void _incrementCounter() {
  Store.of(context).action(_IncrementCounterAction());
}
```
