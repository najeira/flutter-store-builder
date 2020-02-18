import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

import 'provider.dart';
import 'store.dart';

// TODO: subject should be ValueStream<T>
typedef StoredSubjectWidgetBuilder<T> = Widget Function(
  BuildContext context,
  StoredSubject<T> subject,
  Widget child,
);
class SubjectBuilder<T> extends SingleChildStatefulWidget {
  const SubjectBuilder({
    Key key,
    this.store,
    @required this.id,
    @required this.builder,
    Widget child,
  })  : assert(id != null),
        assert(builder != null),
        super(key: key, child: child);

  /// Related to this widget.
  /// If omitted, [SubjectBuilder] will automatically find it
  /// using [StoreProvider] and the current [BuildContext].
  final Store store;

  /// 
  final Object id;

  /// Build a widget tree based on the subject.
  final StoredSubjectWidgetBuilder<T> builder;

  @override
  State<StatefulWidget> createState() {
    return _SubjectBuilderState<T>();
  }
}

/// State for [SubjectBuilder].
class _SubjectBuilderState<T> extends SingleChildState<SubjectBuilder<T>> {
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
  void didUpdateWidget(SubjectBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _unsubscribe();
      _subscribe();
    }
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

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    assert(_subject != null);
    return widget.builder(context, _subject, child);
  }
}
