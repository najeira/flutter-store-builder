import 'dart:async';

import 'package:flutter/material.dart';

import 'package:store_builder/store_builder.dart';

const String title = 'store-builder counter example';

const String counterID = 'identifier for the counter';

void main() => runApp(
      StoreProvider(
        store: Store(),
        child: MaterialApp(
          title: title,
          home: MyHomePage(),
        ),
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
        child: SubjectBuilder<int>(
          id: counterID,
          builder: (BuildContext context, StoredSubject<int> subject, Widget child) {
            if (!subject.hasValue) {
              return const Text('The button has not been pressed yet');
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                child,
                Text(
                  '${subject.value ?? 0}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            );
          },
          child: const Text(
            'You have pushed the button this many times:',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Store store = StoreProvider.of(context);
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
