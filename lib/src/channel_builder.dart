import 'package:flutter/widgets.dart';

import 'store.dart';
import 'provider.dart';

/// Build a Widget using the [BuildContext] and [Value].
typedef ValueWidgetBuilder<V> = Widget Function(
  BuildContext context, V value, Object error);

/// A function that will be run when the [ChannelBuilder] is initialized.
///
/// It is run in the [State.initState] method.
/// 
/// This can be useful for dispatching actions that fetch data for your
/// Widget when it is first displayed.
typedef InitWithValueCallback<S extends StoreBase, V> = void Function(
  S store, V value, Object error);

/// A function that will be run when the [ChannelBuilder] is removed from the
/// Widget Tree.
///
/// It is run in the [State.dispose] method.
///
/// This can be useful for dispatching actions that remove stale data from
/// your State tree.
typedef DisposeCallback<S extends StoreBase> = void Function(
  S store);

/// Build a widget based on the state of the [Store].
/// 
/// Every time the value of [channel] changes, the Widget will be rebuilt.
class ChannelBuilder<S extends StoreBase, V> extends StatelessWidget {
  ChannelBuilder({
    Key key,
    @required this.channel,
    @required this.builder,
    this.onInit,
    this.onDispose,
  })
    : assert(channel != null),
      assert(builder != null),
      super(key: key);
  
  /// A key to the value of the [Store].
  final Channel<V> channel;
  
  /// 
  final ValueWidgetBuilder<V> builder;
  
  /// 
  final InitWithValueCallback<S, V> onInit;
  
  /// 
  final DisposeCallback<S> onDispose;
  
  @override
  Widget build(BuildContext context) {
    final S store = StoreProvider.of<S>(context);
    return new _ChannelBuilder<S, V>(
      store: store,
      channel: channel,
      builder: builder,
      onInit: onInit,
      onDispose: onDispose,
    );
  }
}

class _ChannelBuilder<S extends StoreBase, V> extends StatefulWidget {
  _ChannelBuilder({
    Key key,
    @required this.store,
    @required this.channel,
    @required this.builder,
    this.onInit,
    this.onDispose,
  })
    : assert(store != null),
      assert(channel != null),
      assert(builder != null),
      super(key: key);
  
  final S store;
  final Channel<V> channel;
  final ValueWidgetBuilder<V> builder;
  final InitWithValueCallback<S, V> onInit;
  final DisposeCallback<S> onDispose;
  
  @override
  State<StatefulWidget> createState() {
    return new _ChannelBuilderState<S, V>();
  }
}

class _ChannelBuilderState<S extends StoreBase, V> extends State<_ChannelBuilder<S, V>> {
  @override
  void initState() {
    super.initState();
    widget.channel.addListener(_onValueUpdated);
    if (widget.onInit != null) {
      final Value<V> value = widget.channel.get();
      widget.onInit(widget.store, value?.value, value?.error);
    }
  }
  
  @override
  void didUpdateWidget(_ChannelBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel) {
      oldWidget.channel.removeListener(_onValueUpdated);
      widget.channel.addListener(_onValueUpdated);
    }
  }
  
  @override
  void dispose() {
    if (widget.onDispose != null) {
      widget.onDispose(widget.store);
    }
    widget.channel.removeListener(_onValueUpdated);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final Value<V> value = widget.channel.get();
    return widget.builder(context, value?.value, value?.error);
  }
  
  void _onValueUpdated(Value<V> value) {
    setState(() {});
  }
}
