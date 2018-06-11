import 'package:flutter/widgets.dart';

import 'store.dart';

/// Provides a Flux [Store] to all ancestors of this Widget.
/// This should generally be a root widget in your App.
/// Connect to the [Store] provided by this Widget using a 
/// [ChannelBuilder].
class StoreProvider extends InheritedWidget {
  final Store store;
  
  const StoreProvider({
    Key key,
    @required this.store,
    @required Widget child,
  })
    : assert(store != null),
      assert(child != null),
      super(key: key, child: child);
  
  static Store of(BuildContext context) {
    final StoreProvider provider = context.inheritFromWidgetOfExactType(StoreProvider);
    return provider?.store;
  }
  
  @override
  bool updateShouldNotify(StoreProvider old) {
    return store != old.store;
  }
}
