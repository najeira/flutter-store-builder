import 'dart:async';

import 'store.dart';

abstract class Action {
  const Action();
  
  Future<void> run(Store store);
}
