import 'dart:async';

import 'package:flutter/material.dart';

import 'package:store_builder/store_builder.dart';

const String _title = 'Flux store builder';

const String _counterName = 'identifier for the counter';

void main() => runApp(MaterialApp(
      title: _title,
      home: StoreProvider(
        store: Store(),
        child: MyHomePage(),
      ),
    ));

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: Center(
        child: StoreBuilder<int>(
          name: _counterName,
          builder: (BuildContext context, Value<int> value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '${value.value ?? 0}',
                  style: Theme.of(context).textTheme.display1,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Store.of(context).action(_IncrementCounterAction());
          // or: _IncrementCounterAction().run(Store.of(context));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _IncrementCounterAction implements Action {
  Future<void> run(Store store) async {
    final int counter = store.get<int>(_counterName).value ?? 0;
    store.set<int>(_counterName, counter + 1);
  }
}
