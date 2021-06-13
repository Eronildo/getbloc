<p align="center">
<img src="https://raw.githubusercontent.com/Eronildo/getbloc/main/docs/assets/getbloc_logo.png" height="100" alt="GetBloc" />
</p>

---

A dart package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc) with [GetX](https://github.com/jonataslaw/getx).

This package is built to work with:

- [getbloc_test](https://pub.dev/packages/getbloc_test)

---

# GetBloc

Create GetX Controllers with Events and/or States, instead using Provider as the bloc library uses, GetBloc uses GetX.

## Overview

The purpose of this library is to apply the pattern used by the bloc library in GetX Controllers, facilitating maintainability, enabling better teamwork in project development.

### StateController

A `StateController` is class which extends `BaseController` and can be extended to manage any type of state. `StateController` requires an initial state which will be the state before `emit` has been called. The current state of a `controller` can be accessed via the `state` getter and the state of the `controller` can be updated by calling `emit` with a new `state`.

#### Creating a StateController

```dart
/// A `CounterController` which manages an `int` as its state.
class CounterController extends StateController<int> {
  /// The initial state of the `CounterController` is 0.
  CounterController() : super(0);

  /// When increment is called, the current state
  /// of the controller is accessed via `state` and
  /// a new `state` is emitted via `emit`.
  void increment() => emit(state + 1);
}
```

#### Using a Controller

```dart
void main() {
  /// Create a `CounterController` instance.
  final controller = CounterController();

  /// Access the state of the `controller` via `state`.
  print(controller.state); // 0

  /// Interact with the `controller` to trigger `state` changes.
  controller.increment();

  /// Access the new `state`.
  print(controller.state); // 1

  /// Close the `controller` when it is no longer needed.
  controller.close();
}
```

#### Observing a Controller

`onChange` can be overridden to observe state changes for a single `controller`.

`onError` can be overridden to observe errors for a single `controller`.

```dart
class CounterController extends StateController<int> {
  CounterController() : super(0);

  void increment() => emit(state + 1);

  @override
  void onChange(StateChange<int> change) {
    super.onChange(change);
    print(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
```

`ObserverController` can be used to observe all `controllers`.

```dart
class MyObserverController extends ObserverController {
  @override
  void onCreate(BaseController controller) {
    super.onCreate(controller);
    print('onCreate -- ${controller.runtimeType}');
  }

  @override
  void onChange(BaseController controller, StateChange change) {
    super.onChange(controller, change);
    print('onChange -- ${controller.runtimeType}, $change');
  }

  @override
  void onError(BaseController controller, Object error, StackTrace stackTrace) {
    print('onError -- ${controller.runtimeType}, $error');
    super.onError(controller, error, stackTrace);
  }

  @override
  void onClose(BaseController controller) {
    super.onClose(controller);
    print('onClose -- ${controller.runtimeType}');
  }
}
```

```dart
void main() {
  Controller.observer = MyObserverController();
  // Use controllers...
}
```

### Controller

A `Controller` is a more advanced class which relies on `events` to trigger `state` changes rather than functions. `Controller` also extends `BaseController` which means it has a similar public API as `StateController`. However, rather than calling a `function` on a `Controller` and directly emitting a new `state`, `Controllers` receive `events` and convert the incoming `events` into outgoing `states`.

#### Creating a Controller

```dart
/// The events which `CounterController` will react to.
enum CounterEvent { increment }

/// A `CounterController` which handles converting `CounterEvent`s into `int`s.
class CounterController extends Controller<CounterEvent, int> {
  /// The initial state of the `CounterController` is 0.
  CounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      /// When a `CounterEvent.increment` event is added,
      /// the current `state` of the controller is accessed via the `state` property
      /// and a new state is emitted via `yield`.
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

#### Using a Controller

```dart
void main() async {
  /// Create a `CounterController` instance.
  final controller = CounterController();

  /// Access the state of the `controller` via `state`.
  print(controller.state); // 0

  /// Interact with the `controller` to trigger `state` changes.
  controller.add(CounterEvent.increment);

  /// Wait for next iteration of the event-loop
  /// to ensure event has been processed.
  await Future.delayed(Duration.zero);

  /// Access the new `state`.
  print(controller.state); // 1

  /// Close the `controller` when it is no longer needed.
  controller.close();
}
```

#### Observing a Controller

Since all `Controllers` extend `BaseController` just like `StateController`, `onChange` and `onError` can be overridden in a `Controller` as well.

In addition, `Controllers` can also override `onEvent` and `onTransform`.

`onEvent` is called any time a new `event` is added to the `Controller`.

`onTransform` is similar to `onChange`, however, it contains the `event` which triggered the state change in addition to the `currentState` and `nextState`.

```dart
enum CounterEvent { increment }

class CounterController extends Controller<CounterEvent, int> {
  CounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onEvent(CounterEvent event) {
    super.onEvent(event);
    print(event);
  }

  @override
  void onChange(StateChange<int> change) {
    super.onChange(change);
    print(change);
  }

  @override
  void onTransform(TransformController<CounterEvent, int> transition) {
    super.onTransform(transition);
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
```

`ObserverController` can be used to observe all `controllers` as well.

```dart
class MyObserverController extends ObserverController {
  @override
  void onCreate(BaseController controller) {
    super.onCreate(controller);
    print('onCreate -- ${controller.runtimeType}');
  }

  @override
  void onEvent(Controller controller, Object? event) {
    super.onEvent(controller, event);
    print('onEvent -- ${controller.runtimeType}, $event');
  }

  @override
  void onChange(BaseController controller, StateChange change) {
    super.onChange(controller, change);
    print('onChange -- ${controller.runtimeType}, $change');
  }

  @override
  void onTransform(Controller controller, TransformController transition) {
    super.onTransform(controller, transition);
    print('onTransform -- ${controller.runtimeType}, $transition');
  }

  @override
  void onError(BaseController controller, Object error, StackTrace stackTrace) {
    print('onError -- ${controller.runtimeType}, $error');
    super.onError(controller, error, stackTrace);
  }

  @override
  void onClose(BaseController controller) {
    super.onClose(controller);
    print('onClose -- ${controller.runtimeType}');
  }
}
```

```dart
void main() {
  Controller.observer = MyObserverController();
  // Use controllers...
}
```

## Examples

- [Counter](https://github.com/Eronildo/getbloc/tree/main/packages/getbloc/example) - an example of how to create a `CounterController`.

See more about how to use `Obx`, `GetView` and `Bindings` to hook up a `CounterPage` widget to a `CounterController` in [GetX](https://pub.dev/packages/get).
