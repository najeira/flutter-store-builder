import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// A Store that holds the app state.
class Store {
  Store();

  // ignore: always_specify_types
  final Map<_Key, StoredSubject> _entities = <_Key, StoredSubject>{};

  /// Get a subject in the Store.
  StoredSubject<T> use<T>(
    Object id, {
    T seedValue,
    bool volatile = true,
  }) {
    final Type type = T.runtimeType;
    final _Key key = _Key(type, id);

    StoredSubject<T> subject = _entities[key];

    if (subject == null) {
      // Create a new subject if it is not exists yet.
      subject = StoredSubject<T>._(
        type: type,
        id: id,
        seedValue: seedValue,
        onRelease: () {
          // Remove from the Store when all references are released.
          _entities.remove(key);
        },
      );
      _entities[key] = subject;
    } else {
      // Retain reference count if it is already exists.
      subject._retain();
    }

    return subject;
  }
}

/// 
class StoredSubject<T> {
  StoredSubject._({
    this.type,
    this.id,
    T seedValue,
    void onRelease(),
  })  : _subject = seedValue != null
            ? BehaviorSubject<T>.seeded(seedValue)
            : BehaviorSubject<T>(),
        _onRelease = onRelease {
    _subscription = _subject.listen(
      _onData,
      onError: _onError,
    );
  }

  final Type type;

  final Object id;

  final BehaviorSubject<T> _subject;

  StreamSubscription<T> _subscription;

  ValueStream<T> get stream => _subject;

  StreamSink<T> get sink => _subject;

  bool get isClosed => _subject.isClosed;

  bool get hasValue => _subject.hasValue;

  /// Get the latest value emitted by the Subject
  T get value => _subject.value;

  /// Set and emit the new value
  set value(T newValue) => _subject.value = newValue;

  /// Set and emit the new value
  void add(T event) => _subject.add(event);

  bool _hasError = false;

  bool get hasError => _hasError;

  Object _error;

  Object get error => hasError ? _error : null;

  /// Set and emit the error
  set error(Object error) => _subject.addError(error);

  /// Set and emit the error
  void addError(Object error, [StackTrace stackTrace]) {
    _subject.addError(error, stackTrace);
  }

  StreamSubscription<T> listen(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    return _subject.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  final void Function() _onRelease;

  void _onData(T event) {
    _error = null;
    _hasError = false;
  }

  void _onError(Object error) {
    _error = error;
    _hasError = true;
  }

  int _referenceCount = 1;

  void _retain() {
    assert(_referenceCount >= 0);
    _referenceCount++;
  }

  void release() {
    assert(_referenceCount >= 1);
    _referenceCount--;
    if (_referenceCount <= 0) {
      _subscription?.cancel();
      _subject?.close();
      _onRelease();
    }
  }
}

@immutable
class _Key {
  const _Key(
    this.type,
    this.id,
  ) : assert(type != null);

  final Type type;

  final Object id;

  @override
  int get hashCode {
    final int idh = id?.hashCode ?? 41;
    return type.hashCode ^ idh;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Key && other.type == type && other.id == id;
  }
}
