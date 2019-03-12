import 'dart:async';

import 'package:flutter/widgets.dart';

import 'action.dart';
import 'builder.dart';
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
    final _Holder<V> holder = _holders[name];
    return holder?._value ?? Value<V>.empty();
  }

  /// Stores the [value] for the given [name] to this [Store].
  void set<V>(
    String name,
    V value, {
    Object error,
    bool volatile = true,
  }) {
    _Holder<V> holder = _holders[name];
    if (holder == null && !volatile) {
      // creates a new holder if it is not volatile.
      holder = _Holder<V>();
      _holders[name] = holder;
    }
    holder?.setValue(value, error, volatile);
  }

  // 指定したkeyが更新された場合に通知を受け取るcallbackを登録する
  // 通常、この関数はState.initStateから呼び出される
  // subscribeした場合は、State.disposeでunsubscribeする
  void addListener<V>(
    String name,
    ValueCallback<V> callback, {
    bool distinct = false,
  }) {
    _Holder<V> holder = _holders[name];
    if (holder == null) {
      holder = _Holder<V>();
      _holders[name] = holder;
    }
    holder.addListener(callback, distinct: distinct);
  }

  // 指定したkeyに登録したcallbackを解除する
  // 通常、この関数はState.disposeから呼び出される
  void removeListener<V>(String name, ValueCallback<V> callback) {
    final holder = _holders[name];
    if (holder != null) {
      holder.removeListener(callback);
      if (holder.disposable) {
        _holders.remove(name);
      }
    }
  }
}

class _Holder<V> {
  final Map<ValueCallback<V>, bool> _listeners = <ValueCallback<V>, bool>{};

  Value<V> _value;

  bool _volatile = true;

  void setValue(V value, Object error, bool volatile) {
    final bool changed = (value != _value?.value || error != _value?.error);
    if (changed || _value == null) {
      _value = Value<V>(value, error);
    }
    _volatile = volatile;
    Future.delayed(Duration.zero, () {
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
    return _volatile && _listeners.length <= 0;
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
