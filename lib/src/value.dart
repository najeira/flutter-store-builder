import 'package:flutter/foundation.dart';

/// 
@immutable
class Value<V> {
  /// 
  const Value(this.value, this.error);
  
  /// 
  const Value.empty() : this(null, null);
  
  /// 
  final V value;
  
  /// 
  final Object error;
  
  /// 
  bool get isEmpty {
    return value == null && error == null;
  }
  
  /// 
  bool get isNotEmpty {
    return !isEmpty;
  }
}
