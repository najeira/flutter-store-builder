import 'store.dart';

/// Defines an action handler to produce new state.
typedef void Producer<S extends StoreBase>(S store, dynamic action);

/// Defines a [Producer] using a class interface.
abstract class ProducerClass<S extends StoreBase> {
  void call(S store, dynamic action);
}

/// A convenience class for binding [Producer]s to Actions of a given Type.
class TypedProducer<S extends StoreBase, Action> implements ProducerClass<S> {
  const TypedProducer(this.producer);
  
  final void Function(S store, Action action) producer;

  @override
  void call(S store, dynamic action) {
    if (action is Action) {
      producer(store, action);
    }
  }
}

/// Creates a Producer that dispatches actions to producers.
/// 
/// ### Example:
/// 
///     const Map<Type, ProducerClass<Store>> producers = const <Type, ProducerClass<Store>>{
///       FooAction: const TypedProducer<Store, FooAction>(fooProducer),
///       BarAction: const TypedProducer<Store, BarAction>(barProducer),
///     };
///     var producer = combineProducer(producers);
///     var store = new Store(producer);
/// 
Producer<S> combineProducer<S extends StoreBase>(Map<Type, ProducerClass<S>> producers) {
  return (S store, dynamic action) {
    final producer = producers[action.runtimeType];
    if (producer != null) {
      producer.call(store, action);
    }
  };
}
