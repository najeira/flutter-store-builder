import 'dart:async';

import 'package:flutter/material.dart';

import 'package:store_builder/store_builder.dart';

const String title = 'Flux store builder';

final Store store = Store();

const String counterID = 'identifier for the counter';

void main() => runApp(
      MaterialApp(
        title: title,
        home: MyHomePage(),
      ),
    );

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StoreBuilder<int>(
              store: store,
              id: counterID,
              builder: (BuildContext context, StoredSubject<int> subject) {
                return Text(
                  '${subject.value ?? 0}',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          incrementCounter(store);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> incrementCounter(Store store) async {
  final StoredSubject<int> subject = store.use<int>(counterID);
  try {
    final int counter = subject.value ?? 0;
    subject.value = counter + 1;
  } finally {
    subject.release();
  }
}
