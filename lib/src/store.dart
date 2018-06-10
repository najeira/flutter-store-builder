import 'dart:async';

import 'package:flutter/foundation.dart';

import 'producer.dart';

typedef ValueCallback<V>(Value<V> value);

/// A Flux store that holds the app state.
///
/// The only way to change the state in the store is to [dispatch] an action.
/// The action will be sent to the given [Producer] to handle it.
/// 
/// Extends [StoreBase] to provide app's Store.
class StoreBase {
  StoreBase(Producer producer)
    :
      _producer = producer,
      _holders = <String, _Holder>{};
  
  final Producer _producer;
  
  final Map<String, _Holder> _holders;
  
  /// Creates a [Channel] for the given [name].
  Channel<V> chan<V>(String name, {bool volatile = true}) {
    return new Channel(this, name, volatile: volatile);
  }
  
  /// Disptaches a [action].
  Future<void> dispatch(dynamic action) {
    return _producer.call(this, action);
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
  void _removeListener(String name, ValueCallback callback) {
    final holder = this._holders[name];
    if (holder != null) {
      holder.removeListener(callback);
      if (holder.disposable) {
        this._holders.remove(name);
      }
    }
  }
}

/// 
@immutable
class Value<V> {
  Value(this.value, this.error);
  
  Value.empty() : this(null, null);
  
  /// 
  final V value;
  
  /// 
  final Object error;
  
  bool get isEmpty {
    return value == null && error == null;
  }
  
  bool get isNotEmpty {
    return !isEmpty;
  }
}

class _Holder<V> {
  _Holder(this.volatile);
  
  final bool volatile;
  
  final Map<ValueCallback<V>, bool> _listeners = <ValueCallback<V>, bool>{};
  
  Value<V> _value;
  
  void setValue(V value, Object error) {
    final bool changed = (value != _value.value || error != _value.error);
    _value = new Value(value, error);
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

class Channel<V> {
  const Channel(this.store, this.name, {this.volatile = true});
  
  final StoreBase store;
  
  final String name;
  
  final bool volatile;
  
  Value<V> get() {
    return store._get<V>(name);
  }
  
  void set(V value, [Object error]) {
    store._set(name, value: value, error: error, volatile: volatile);
  }
  
  void error(Object error) {
    store._set(name, value: null, error: error, volatile: volatile);
  }
  
  void addListener(ValueCallback<V> callback, {bool distinct = false}) {
    store._addListener(name, callback, distinct: distinct, volatile: volatile);
  }
  
  void removeListener(ValueCallback<V> callback) {
    store._removeListener(name, callback);
  }
  
  @override
  int get hashCode {
    return identityHashCode(store) ^ identityHashCode(name);
  }
  
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Channel
      && other.store == store
      && other.name == name;
  }
}
