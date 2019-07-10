import 'dart:async';

import 'package:flutter/material.dart';

import 'package:store_builder/store_builder.dart';

const String _title = 'Flux store builder';

class Names {
  static const String counter = 'identifier for the counter';
}

class Values {
  static Value<int> counter(Store store) => store.value<int>(Names.counter);
}

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StoreBuilder<int>(
              name: Names.counter,
              builder: (BuildContext context, Value<int> value) {
                return Text(
                  '${value.value ?? 0}',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          incrementCounter(Store.of(context));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> incrementCounter(Store store) async {
  final Value<int> value = Values.counter(store);
  final int count = value.value ?? 0;
  value.value = count + 1;
}
