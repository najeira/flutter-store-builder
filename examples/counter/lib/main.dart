import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      title: 'Flux store builder',
      home: StoreProvider(
        store: Store(),
        child: MyHomePage(),
      ),
    ));

const String _counterName = 'this is identifier for counter';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flux store builder'),
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
                  '${value.value}',
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
    final int counter = store.get<int>(_counterName);
    store.set<int>(_counterName, counter + 1);
  }
}
