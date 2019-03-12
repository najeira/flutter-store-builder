import 'dart:async';

import 'package:flutter/widgets.dart';

import 'action.dart';
import 'channel_builder.dart';
import 'provider.dart';
import 'value.dart';

/// A Flux store that holds the app state.
class Store {
  Store();
  
  final Map<String, _Holder> _holders = <String, _Holder>{};
  
  static Store of(BuildContext context) {
    return StoreProvider.of(context);
  }
  
  /// Runs a [action].
  Future<void> action(Action action) {
    return action.run(this);
  }
  
  /// Returns the value for the given [name] or null if [name] is not in the [Store].
  Value<V> get<V>(String name) {
    final holder = this._holders[name];
    if (holder != null && holder._value != null) {
      return holder._value as Value<V>;
    }
    return new Value<V>.empty();
  }
  
  /// Stores the [value] for the given [name] to [Store].
  void set<V>(String name, {
    V value,
    Object error,
    bool volatile = true,
  }) {
    var holder = this._holders[name];
    if (holder == null && !volatile) {
      holder = new _Holder<V>(volatile);
      this._holders[name] = holder;
    }
    holder?.setValue(value, error);
  }
  
  // 指定したkeyが更新された場合に通知を受け取るcallbackを登録する
  // 通常、この関数はState.initStateから呼び出される
  // subscribeした場合は、State.disposeでunsubscribeする
  void addListener<V>(String name, ValueCallback<V> callback, {
    bool distinct = false,
    bool volatile = true,
  }) {
    _Holder<V> holder = this._holders[name];
    if (holder == null) {
      holder = new _Holder<V>(volatile);
      this._holders[name] = holder;
    }
    holder.addListener(callback, distinct: distinct);
  }
  
  // 指定したkeyに登録したcallbackを解除する
  // 通常、この関数はState.disposeから呼び出される
  void removeListener<V>(String name, ValueCallback<V> callback) {
    final holder = this._holders[name];
    if (holder != null) {
      holder.removeListener(callback);
      if (holder.disposable) {
        this._holders.remove(name);
      }
    }
  }
}

class _Holder<V> {
  _Holder(this.volatile);
  
  final bool volatile;
  
  final Map<ValueCallback<V>, bool> _listeners = <ValueCallback<V>, bool>{};
  
  Value<V> _value;
  
  void setValue(V value, Object error) {
    final bool changed = (value != _value?.value || error != _value?.error);
    _value = new Value<V>(value, error);
    new Future.delayed(Duration.zero, () {
      _callListeners(changed);
    });
  }
  
  void _callListeners(bool changed) {
    _listeners.forEach((ValueCallback<V> listener, bool distinct) {
      if (changed || !distinct) {
        listener(_value);
      }
    });
  }
  
  bool get disposable {
    return volatile && _listeners.length <= 0;
  }
  
  void addListener(ValueCallback<V> listener, {bool distinct = false}) {
    assert(listener != null);
    _listeners[listener] = distinct;
  }
  
  void removeListener(ValueCallback<V> listener) {
    assert(listener != null);
    _listeners.remove(listener);
  }
}
