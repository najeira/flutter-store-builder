import 'package:flutter/foundation.dart';

import 'producer.dart';

typedef ValueCallback<V>(Value<V> value);

/// 
class StoreBase {
  StoreBase(Producer producer)
    :
      _producer = producer,
      _holders = <String, _Holder>{};
  
  final Producer _producer;
  
  final Map<String, _Holder> _holders;
  
  Channel<V> chan<V>(String name) {
    return new Channel(this, name);
  }
  
  /// Disptaches a [action].
  void dispatch(dynamic action) {
    _producer(this, action);
  }
  
  /// Returns the value for the given [name] or null if [name] is not in the [Store].
  Value<V> _get<V>(String name) {
    final holder = this._holders[name];
    if (holder != null && holder._value != null) {
      return holder._value as Value<V>;
    }
    return null;
  }
  
  /// Stores the [value] for the given [name] to [Store].
  void _set<V>(String name, V value, [Object error]) {
    final holder = this._holders[name];
    if (holder != null) {
      // 値を必要とするStoreBuilderから関連するActionが発行され
      // その結果として値が得られputされる
      // よってholderがいる場合だけ値を保持する
      holder.setValue(value, error);
    }
  }
  
  // 指定したkeyが更新された場合に通知を受け取るcallbackを登録する
  // 通常、この関数はState.initStateから呼び出される
  // subscribeした場合は、State.disposeでunsubscribeする
  void _addListener<V>(String name, ValueCallback<V> callback) {
    _Holder<V> holder = this._holders[name];
    if (holder == null) {
      holder = new _Holder<V>();
      this._holders[name] = holder;
    }
    holder.addListener(callback);
  }
  
  // 指定したkeyに登録したcallbackを解除する
  // 通常、この関数はState.disposeから呼び出される
  void _removeListener(String name, ValueCallback callback) {
    final holder = this._holders[name];
    if (holder != null) {
      holder.removeListener(callback);
      if (!(holder.hasListeners)) {
        this._holders.remove(name);
      }
    }
  }
}

/// 
@immutable
class Value<V> {
  const Value(this.value, this.error);
  
  /// 
  final V value;
  
  /// 
  final Object error;
}

class _Holder<V> {
  final List<ValueCallback<V>> _listeners = <ValueCallback<V>>[];
  
  Value<V> _value;
  
  void setValue(V value, Object error) {
    if (value == _value.value && error == _value.error) {
      return;
    }
    _value = new Value(value, error);
    for (var listener in _listeners) {
      listener(_value);
    }
  }
  
  bool get hasListeners {
    return _listeners.length > 0;
  }
  
  void addListener(ValueCallback<V> listener) {
    assert(listener != null);
    _listeners.add(listener);
  }
  
  void removeListener(ValueCallback<V> listener) {
    assert(listener != null);
    _listeners.remove(listener);
  }
}

class Channel<V> {
  Channel(this.store, this.name);
  
  final StoreBase store;
  
  final String name;
  
  Value<V> get() {
    return store._get<V>(name);
  }
  
  void set(V value, [Object error]) {
    store._set(name, value, error);
  }
  
  void error(Object error) {
    store._set(name, null, error);
  }
  
  void addListener<V>(ValueCallback<V> callback) {
    store._addListener(name, callback);
  }
  
  void removeListener(ValueCallback<V> callback) {
    store._removeListener(name, callback);
  }
  
  ValueCallback<V> createValueCallback(VoidCallback callback) {
    return (Value<V> value) {
      callback();
    };
  }
}
