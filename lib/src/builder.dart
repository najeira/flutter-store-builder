import 'dart:async';

import 'package:flutter/material.dart';

import 'provider.dart';
import 'store.dart';

// TODO: subject should be ValueStream<T>
typedef StoredSubjectWidgetBuilder<T> = Widget Function(BuildContext context, StoredSubject<T> subject);

class StoreBuilder<T> extends StatefulWidget {
  const StoreBuilder({
    Key key,
    this.store,
    @required this.id,
    @required this.builder,
  })  : assert(id != null),
        assert(builder != null),
        super(key: key);

  final Store store;

  final Object id;

  final StoredSubjectWidgetBuilder<T> builder;

  @override
  State<StatefulWidget> createState() {
    return _StoreBuilderState<T>();
  }
}

/// State for [StoreBuilder].
class _StoreBuilderState<T> extends State<StoreBuilder<T>> {
  StoredSubject<T> _subject;

  StreamSubscription<T> _subscription;

  Store get _store {
    return widget.store ?? StoreProvider.of(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void didUpdateWidget(StoreBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(_subject != null);
    return widget.builder(context, _subject);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_subject == null) {
      assert(_subscription == null);
      _subject = _store.use<T>(widget.id);
      _subscription = _subject.listen(_onData);
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    if (_subject != null) {
      _subject.release();
      _subject = null;
    }
  }

  void _onData(T event) {
    setState(() {});
  }
}
