import 'dart:async';

import 'package:flutter/widgets.dart';

import 'provider.dart';

/// 
typedef StoreOperation = void Function(Store store);

/// 
typedef ValueCallback<V> = void Function(Value<V> value);

/// A Flux store that holds the app state.
class Store {
  Store();

  final Map<String, _Entity> _entities = Map<String, _Entity>();

  final Map<String, Map<ValueCallback, bool>> _listeners =
      Map<String, Map<ValueCallback, bool>>();

  /// Returns the [Store] associated with [context].
  static Store of(BuildContext context) {
    return StoreProvider.of(context);
  }

  /// Returns the value for the given [name] or null if [name] is not in the
  /// [Store].
  Value<V> value<V>(String name) {
    return Value<V>(store: this, name: name);
  }

  bool contains(String name) {
    return _entities.containsKey(name);
  }

  _Entity<V> _getEntity<V>(String name) {
    return _entities[name] as _Entity<V>;
  }

  void _setEntity<V>(
    String name, {
    V value,
    Object error,
  }) {
    final _Entity<V> entity = _entities[name];
    if (entity != null) {
      final bool changed = entity.value != value || entity.error != error;
      entity.value = value;
      entity.error = error;
      _callListeners<V>(name, changed);
    } else {
      _entities[name] = _Entity<V>(value: value, error: error);
      _callListeners<V>(name, true);
    }
  }

  void _setVolatile<V>(String name, bool volatile) {
    volatile ??= true;

    final _Entity<V> entity = _entities[name];
    if (entity != null) {
      entity.volatile = volatile;
    } else {
      _entities[name] = _Entity<V>(volatile: volatile);
    }
  }

  // 指定したkeyが更新された場合に通知を受け取るlistenerを登録する
  // 通常、この関数はState.initStateから呼び出される
  // subscribeした場合は、State.disposeでunsubscribeする
  void addListener<V>(
    String name,
    ValueCallback<V> listener, {
    bool distinct = false,
  }) {
    assert(name != null);
    assert(listener != null);

    Map<ValueCallback, bool> map = _listeners[name];
    if (map == null) {
      map = Map<ValueCallback, bool>();
      _listeners[name] = map;
    }

    map[listener] = distinct;
  }

  // 指定したkeyに登録したlistenerを解除する
  // 通常、この関数はState.disposeから呼び出される
  void removeListener<V>(String name, ValueCallback<V> listener) {
    assert(name != null);
    assert(listener != null);

    final Map<ValueCallback, bool> map = _listeners[name];
    if (map == null) {
      return;
    }

    map.remove(listener);
    if (map.isNotEmpty) {
      return;
    }

    _listeners.remove(name);

    // no listeners, remove the volatile value.
    final _Entity<V> entity = _entities[name];
    if (entity?.volatile ?? false) {
      _entities.remove(name);
    }
  }

  void _callListeners<V>(String name, bool changed) {
    Future.delayed(Duration.zero, () {
      _callListenersImpl<V>(name, changed);
    });
  }

  void _callListenersImpl<V>(String name, bool changed) {
    final Map<ValueCallback, bool> map = _listeners[name];
    if (map == null || map.isEmpty) {
      return;
    }

    final Value<V> v = value<V>(name);
    map.forEach((ValueCallback listener, bool distinct) {
      assert(listener is ValueCallback<V>);
      if (changed || !distinct) {
        listener(v);
      }
    });
  }
}

class Value<V> {
  ///
  Value({
    @required this.store,
    @required this.name,
  })  : assert(store != null),
        assert(name != null);

  final Store store;

  final String name;

  _Entity<V> get _entity => store._getEntity<V>(name);

  ///
  V get value => _entity?.value;

  ///
  set value(V newValue) {
    final _Entity<V> entity = _entity;
    store._setEntity(name, value: newValue, error: entity?.error);
  }

  ///
  Object get error => _entity?.error;

  ///
  set error(Object newError) {
    final _Entity<V> entity = _entity;
    store._setEntity(name, value: entity?.value, error: newError);
  }

  ///
  void update(V newValue, Object newError) {
    store._setEntity(name, value: newValue, error: newError);
  }

  ///
  bool get isEmpty {
    final _Entity<V> entity = _entity;
    return entity?.value == null && entity?.error == null;
  }

  ///
  bool get isNotEmpty {
    return !isEmpty;
  }

  ///
  bool get volatile => _entity?.volatile;

  ///
  set volatile(bool newVolatile) {
    store._setVolatile(name, newVolatile);
  }

  void addListener(ValueCallback<V> listener, {bool distinct = false}) {
    store.addListener(name, listener, distinct: distinct);
  }

  void removeListener(ValueCallback<V> listener) {
    store.removeListener(name, listener);
  }

  @override
  int get hashCode {
    final a = store?.hashCode ?? 41;
    final b = name?.hashCode ?? 23;
    return a ^ b;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Value<V> && other.store == store && other.name == name;
  }
}

/// Substantial of the value.
class _Entity<V> {
  _Entity({
    this.value,
    this.error,
    this.volatile = true,
  });

  V value;

  Object error;

  bool volatile;
}
