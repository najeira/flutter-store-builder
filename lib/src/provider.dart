import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'store.dart';

/// Provides a [Store] to all ancestors of this Widget.
/// This should generally be a root widget in your App.
/// Connect to the [Store] provided by this Widget using a
/// [StoreBuilder].
class StoreProvider extends SingleChildStatelessWidget {
  const StoreProvider({
    Key key,
    @required this.store,
    @required Widget child,
  })  : assert(store != null),
        assert(child != null),
        super(key: key, child: child);

  final Store store;

  static Store of(BuildContext context) {
    return Provider.of<Store>(context, listen: false);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return InheritedProvider<Store>(
      create: (BuildContext context) => store,
      child: child,
    );
  }
}

class SubjectProvider<T> extends SingleChildStatelessWidget {
  const SubjectProvider({
    Key key,
    this.store,
    @required this.id,
    @required Widget child,
  })  : assert(store != null),
        assert(child != null),
        super(key: key, child: child);

  final Store store;

  final Object id;

  StoredSubject<T> _create(BuildContext context) {
    final Store store = this.store ?? StoreProvider.of(context);
    return store.use<T>(id);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    // observe changes of the subject itself and handle its lifetime
    return InheritedProvider<StoredSubject<T>>(
      create: (BuildContext context) {
        return _create(context);
      },
      update: (BuildContext context, StoredSubject<T> previous) {
        if (id == previous.id) {
          return previous;
        }
        // previous.release(); // dispose will be call for previous?
        return _create(context);
      },
      dispose: (BuildContext context, StoredSubject<T> subject) {
        subject.release();
      },
      child: Consumer<StoredSubject<T>>(
        builder: (BuildContext context, StoredSubject<T> subject, Widget child) {
          // observe changes of values and errors of the subject
          // provide values of the subject
          return ValueListenableProvider<T>.value(
            value: subject,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
