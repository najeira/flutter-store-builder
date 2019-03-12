import 'package:flutter/widgets.dart';

import 'provider.dart';
import 'store.dart';
import 'value.dart';

typedef ValueCallback<V>(Value<V> value);

/// Build a Widget using the [BuildContext] and [Value].
typedef ValueWidgetBuilder<V> = Widget Function(
  BuildContext context, Value<V> value);

/// Called when the [StoreBuilder] is inserted into the Widget tree.
///
/// It is run in the [State.initState] method.
/// 
/// This can be useful for dispatching actions that fetch data for your
/// Widget when it is first displayed.
typedef InitWithValueCallback<V> = void Function(
  Store store, Value<V> value);

/// Called when the [StoreBuilder] is removed from the Widget tree.
///
/// It is run in the [State.dispose] method.
///
/// This can be useful for dispatching actions that remove stale data from
/// your State tree.
typedef DisposeCallback = void Function(
  Store store);

/// Called when the [Value] is updated.
/// 
/// It will be called before calling the builder.
/// 
/// This can be useful for imperative calls to things like Navigator,
/// TabController, etc.
typedef OnUpdatedCallback<V> = void Function(
  Store store, Value<V> value);

/// Build a widget based on the value of the [name].
/// 
/// Every time the value of [name] changes, the Widget will be rebuilt.
/// 
/// Example:
///   return StoreBuilder<Article>(
///     name: "article-${id}",
///     onInit: (Store store, Value<Article> value) {
///       if (value.value == null) {
///         store.action(LoadArticleAction(id));
///       }
///     },
///     builder: (BuildContext context, Value<Article> value) {
///       if (value.error != null) {
///         return ErrorWidget(value.error);
///       } else if (value.value == null) {
///         return LoadingWidget();
///       }
///       return YourWidget(value.value);
///     },
///   );
/// 
class StoreBuilder<V> extends StatelessWidget {
  StoreBuilder({
    Key key,
    @required this.name,
    @required this.builder,
    this.onInit,
    this.onDispose,
    this.onUpdated,
    this.distinct = false,
  })
    : assert(name != null),
      assert(builder != null),
      super(key: key);
  
  /// A key to the value of the [Store].
  final String name;
  
  /// 
  final ValueWidgetBuilder<V> builder;
  
  /// 
  final InitWithValueCallback<V> onInit;
  
  /// 
  final DisposeCallback onDispose;
  
  /// 
  final OnUpdatedCallback<V> onUpdated;
  
  /// As a performance optimization, 
  /// the Widget can be rebuilt only when the [V] changes. 
  /// 
  /// In order for this to work correctly, you must implement [==] and
  /// [hashCode] for the [V], and set the [distinct] to true when creating
  /// your [StoreBuilder].
  final bool distinct;
  
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of(context);
    return new _StoreBuilder<V>(
      store: store,
      name: name,
      builder: builder,
      onInit: onInit,
      onDispose: onDispose,
      onUpdated: onUpdated,
      distinct: distinct,
    );
  }
}

class _StoreBuilder<V> extends StatefulWidget {
  _StoreBuilder({
    Key key,
    @required this.store,
    @required this.name,
    @required this.builder,
    this.onInit,
    this.onDispose,
    this.onUpdated,
    this.distinct,
  })
    : assert(store != null),
      assert(name != null),
      assert(builder != null),
      super(key: key);
  
  final Store store;
  final String name;
  final ValueWidgetBuilder<V> builder;
  final InitWithValueCallback<V> onInit;
  final DisposeCallback onDispose;
  final OnUpdatedCallback<V> onUpdated;
  final bool distinct;
  
  @override
  State<StatefulWidget> createState() {
    return new _StoreBuilderState<V>();
  }
}

class _StoreBuilderState<V> extends State<_StoreBuilder<V>> {
  @override
  void initState() {
    super.initState();
    
    // call addListener before onInit to hold the value of the name.
    _subscribe(widget);
    
    _callOnInit();
  }
  
  @override
  void didUpdateWidget(_StoreBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name || oldWidget.store != widget.store) {
      _unsubscribe(oldWidget);
      _subscribe(widget);
      
      // call onInit to update StoreBuilder
      _callOnInit();
    }
  }
  
  void _callOnInit() {
    if (widget.onInit != null) {
      final Value<V> value = widget.store.get(widget.name);
      widget.onInit(widget.store, value);
    }
  }
  
  void _subscribe(_StoreBuilder w) {
    w.store.addListener<V>(
      w.name,
      _onValueUpdated,
      distinct: w.distinct,
    );
  }
  
  void _unsubscribe(_StoreBuilder w) {
    w.store.removeListener<V>(
      w.name,
      _onValueUpdated,
    );
  }
  
  @override
  void dispose() {
    _unsubscribe(widget);
    if (widget.onDispose != null) {
      widget.onDispose(widget.store);
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final Value<V> value = widget.store.get(widget.name);
    return widget.builder(context, value);
  }
  
  void _onValueUpdated(Value<V> value) {
    if (mounted) {
      if (widget.onUpdated != null) {
        widget.onUpdated(widget.store, value);
      }
      setState(() {});
    }
  }
}
