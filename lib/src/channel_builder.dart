import 'package:flutter/widgets.dart';

import 'provider.dart';
import 'store.dart';
import 'value.dart';

typedef ValueCallback<V>(Value<V> value);

/// Build a Widget using the [BuildContext] and [Value].
typedef ValueWidgetBuilder<V> = Widget Function(
  BuildContext context, Value<V> value);

/// Called when the [ChannelBuilder] is inserted into the Widget tree.
///
/// It is run in the [State.initState] method.
/// 
/// This can be useful for dispatching actions that fetch data for your
/// Widget when it is first displayed.
typedef InitWithValueCallback<V> = void Function(
  Store store, Value<V> value);

/// Called when the [ChannelBuilder] is removed from the Widget tree.
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

/// Build a widget based on the value of the [Channel].
/// 
/// Every time the value of [channel] changes, the Widget will be rebuilt.
class ChannelBuilder<V> extends StatelessWidget {
  ChannelBuilder({
    Key key,
    @required this.channel,
    @required this.builder,
    this.onInit,
    this.onDispose,
    this.onUpdated,
    this.distinct = false,
  })
    : assert(channel != null),
      assert(builder != null),
      super(key: key);
  
  /// A key to the value of the [Store].
  final Channel<V> channel;
  
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
  /// your [ChannelBuilder].
  final bool distinct;
  
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of(context);
    return new _ChannelBuilder<V>(
      store: store,
      channel: channel,
      builder: builder,
      onInit: onInit,
      onDispose: onDispose,
      onUpdated: onUpdated,
      distinct: distinct,
    );
  }
}

class _ChannelBuilder<V> extends StatefulWidget {
  _ChannelBuilder({
    Key key,
    @required this.store,
    @required this.channel,
    @required this.builder,
    this.onInit,
    this.onDispose,
    this.onUpdated,
    this.distinct,
  })
    : assert(store != null),
      assert(channel != null),
      assert(builder != null),
      super(key: key);
  
  final Store store;
  final Channel<V> channel;
  final ValueWidgetBuilder<V> builder;
  final InitWithValueCallback<V> onInit;
  final DisposeCallback onDispose;
  final OnUpdatedCallback<V> onUpdated;
  final bool distinct;
  
  @override
  State<StatefulWidget> createState() {
    return new _ChannelBuilderState<V>();
  }
}

class _ChannelBuilderState<V> extends State<_ChannelBuilder<V>> {
  @override
  void initState() {
    super.initState();
    
    // call addListener before onInit to hold the value of the channel.
    widget.channel.addListener(widget.store, _onValueUpdated, distinct: widget.distinct);
    
    if (widget.onInit != null) {
      final Value<V> value = widget.channel.get(widget.store);
      widget.onInit(widget.store, value);
    }
  }
  
  @override
  void didUpdateWidget(_ChannelBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel || oldWidget.store != widget.store) {
      oldWidget.channel.removeListener(oldWidget.store, _onValueUpdated);
      widget.channel.addListener(widget.store, _onValueUpdated, distinct: widget.distinct);
    }
  }
  
  @override
  void dispose() {
    widget.channel.removeListener(widget.store, _onValueUpdated);
    if (widget.onDispose != null) {
      widget.onDispose(widget.store);
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final Value<V> value = widget.channel.get(widget.store);
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
