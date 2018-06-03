import 'package:flutter/widgets.dart';

import 'store.dart';

/// Provides a Flux [Store] to all ancestors of this Widget.
/// This should generally be a root widget in your App.
/// Connect to the [Store] provided by this Widget using a 
/// [ChannelBuilder] and [StoreBuilder].
class StoreProvider<S extends StoreBase> extends InheritedWidget {
  final S _store;
  
  const StoreProvider({
    Key key,
    @required S store,
    @required Widget child,
  })
    : assert(store != null),
      assert(child != null),
      _store = store,
      super(key: key, child: child);
  
  static S of<S extends StoreBase>(BuildContext context) {
    final type = _typeOf<StoreProvider<S>>();
    final StoreProvider provider = context.inheritFromWidgetOfExactType(type);
    return provider?._store;
  }
  
  static Type _typeOf<T>() => T;
  
  @override
  bool updateShouldNotify(StoreProvider old) {
    return _store != old._store;
  }
}
