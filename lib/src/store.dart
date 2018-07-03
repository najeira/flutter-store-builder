import 'dart:async';

import 'package:flutter/widgets.dart';

import 'action.dart';
import 'channel_builder.dart';
import 'provider.dart';
import 'value.dart';

/// A Flux store that holds the app state.
///
/// The only way to change the state in the store is to [dispatch] an action.
/// The action will be sent to the given [Producer] to handle it.
/// 
/// Extends [Store] to provide app's Store.
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
  Value<V> _get<V>(String name) {
    final holder = this._holders[name];
    if (holder != null && holder._value != null) {
      return holder._value as Value<V>;
    }
    return new Value<V>.empty();
  }
  
  /// Stores the [value] for the given [name] to [Store].
  void _set<V>(String name, {
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
  void _addListener<V>(String name, ValueCallback<V> callback, {
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
  void _removeListener<V>(String name, ValueCallback<V> callback) {
    final holder = this._holders[name];
    if (holder != null) {
      holder.removeListener(callback);
      if (holder.disposable) {
        this._holders.remove(name);
      }
    }
  }
}

/// Example:
///     class Channels {
///       static Channel<String> myName(Store store) {
///         return store.channel("my-name", volatile: false);
///       }
///     }
class Channel<V> {
  const Channel(this.name, {this.volatile = true});
  
  final String name;
  
  final bool volatile;
  
  Value<V> get(Store store) {
    return store._get<V>(name);
  }
  
  void set(Store store, V value, [Object error]) {
    store._set<V>(name, value: value, error: error, volatile: volatile);
  }
  
  void error(Store store, Object error) {
    store._set<V>(name, value: null, error: error, volatile: volatile);
  }
  
  void addListener(Store store, ValueCallback<V> callback, {bool distinct = false}) {
    store._addListener<V>(name, callback, distinct: distinct, volatile: volatile);
  }
  
  void removeListener(Store store, ValueCallback<V> callback) {
    store._removeListener<V>(name, callback);
  }
  
  @override
  int get hashCode {
    return identityHashCode(name) ^ identityHashCode(volatile);
  }
  
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Channel
      && other.volatile == volatile
      && other.name == name;
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
