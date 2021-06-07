import 'dart:async';

import 'package:get/get.dart';
import 'package:meta/meta.dart';

import 'observer_controller.dart';
import 'transform_controller.dart';

/// Signature for a mapper function which takes an [Event] as input
/// and outputs a [Stream] of [TransformController] objects.
typedef TransitionFunction<Event, State>
    = Stream<TransformController<Event, State>> Function(Event);

/// Exception thrown when an unhandled error occurs within a controller.
///
/// _Note: thrown in debug mode only_
class ControllerUnhandledErrorException implements Exception {
  ControllerUnhandledErrorException(
    this.controller,
    this.error, [
    this.stackTrace = StackTrace.empty,
  ]);

  /// The controller in which the unhandled error occurred.
  final BaseController controller;

  /// The unhandled [error] object.
  final Object error;

  /// Stack trace which accompanied the error.
  /// May be [StackTrace.empty] if no stack trace was provided.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in $controller.\n'
        '$stackTrace';
  }
}

abstract class Controller<Event, State> extends BaseController<State> {
  Controller(State initialState) : super(initialState) {
    _bindEventsToStates();
  }

  /// The current [ObserverController] instance.
  static ObserverController observer = ObserverController();

  StreamSubscription<TransformController<Event, State>>?
      _transitionSubscription;

  // ignore: close_sinks
  StreamController<Event>? __eventController;
  StreamController<Event> get _eventController {
    return __eventController ??= StreamController<Event>.broadcast();
  }

  /// Notifies the [Controller] of a new [event] which triggers [mapEventToState].
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be ignored and will not result in any subsequent state changes.
  void add(Event event) {
    if (_eventController.isClosed) return;
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  /// Called whenever an [event] is [add]ed to the [Controller].
  /// A great spot to add logging/analytics at the individual [Controller] level.
  ///
  /// **Note: `super.onEvent` should always be called first.**
  /// ```dart
  /// @override
  /// void onEvent(Event event) {
  ///   // Always call super.onEvent with the current event
  ///   super.onEvent(event);
  ///
  ///   // Custom onEvent logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [ObserverController.onEvent] for observing events globally.
  ///
  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    observer.onEvent(this, event);
  }

  /// Transforms the [events] stream along with a [transitionFn] function into
  /// a `Stream<Transition>`.
  /// Events that should be processed by [mapEventToState] need to be passed to
  /// [transitionFn].
  /// By default `asyncExpand` is used to ensure all [events] are processed in
  /// the order in which they are received.
  /// You can override [transformEvents] for advanced usage in order to
  /// manipulate the frequency and specificity with which [mapEventToState] is
  /// called as well as which [events] are processed.
  ///
  /// For example, if you only want [mapEventToState] to be called on the most
  /// recent [Event] you can use `switchMap` instead of `asyncExpand`.
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformEvents(events, transitionFn) {
  ///   return events.switchMap(transitionFn);
  /// }
  /// ```
  ///
  /// Alternatively, if you only want [mapEventToState] to be called for
  /// distinct [events]:
  ///
  /// ```dart
  /// @override
  /// Stream<TransformController<Event, State>> transformEvents(events, transitionFn) {
  ///   return super.transformEvents(
  ///     events.distinct(),
  ///     transitionFn,
  ///   );
  /// }
  /// ```
  Stream<TransformController<Event, State>> transformEvents(
    Stream<Event> events,
    TransitionFunction<Event, State> transitionFn,
  ) {
    return events.asyncExpand(transitionFn);
  }

  /// **[emit] should never be used outside of tests.**
  ///
  /// Updates the state of the controller to the provided [state].
  /// A controller's state should only be updated by `yielding` a new `state`
  /// from `mapEventToState` in response to an event.
  @protected
  @visibleForTesting
  @override
  void emit(State state) => super.emit(state);

  /// Must be implemented when a class extends [Controller].
  /// [mapEventToState] is called whenever an [event] is [add]ed
  /// and is responsible for converting that [event] into a new [state].
  /// [mapEventToState] can `yield` zero, one, or multiple states for an event.
  @protected
  @visibleForOverriding
  Stream<State> mapEventToState(Event event);

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed and [mapEventToState]
  /// executed.
  /// [onTransform] is called before a [Controller]'s [state] has been updated.
  /// A great spot to add logging/analytics at the individual [Controller] level.
  ///
  /// **Note: `super.onTransform` should always be called first.**
  /// ```dart
  /// @override
  /// void onTransform(Transition<Event, State> transition) {
  ///   // Always call super.onTransform with the current transition
  ///   super.onTransform(transition);
  ///
  ///   // Custom onTransform logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [ObserverController.onTransform] for observing transitions globally.
  ///
  @protected
  @mustCallSuper
  void onTransform(TransformController<Event, State> transition) {
    // ignore: invalid_use_of_protected_member
    Controller.observer.onTransform(this, transition);
  }

  /// Transforms the `Stream<Transition>` into a new `Stream<Transition>`.
  /// By default [transformTransitions] returns
  /// the incoming `Stream<Transition>`.
  /// You can override [transformTransitions] for advanced usage in order to
  /// manipulate the frequency and specificity at which `transitions`
  /// (state changes) occur.
  ///
  /// For example, if you want to debounce outgoing state changes:
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformTransitions(
  ///   Stream<Transition<Event, State>> transitions,
  /// ) {
  ///   return transitions.debounceTime(Duration(seconds: 1));
  /// }
  /// ```
  Stream<TransformController<Event, State>> transformTransitions(
    Stream<TransformController<Event, State>> transitions,
  ) {
    return transitions;
  }

  /// Closes the `event` and `state` `Streams`.
  /// This method should be called when a [Controller] is no longer needed.
  /// Once [onClose] is called, `events` that are [add]ed will not be
  /// processed.
  /// In addition, if [onClose] is called while `events` are still being
  /// processed, the [Controller] will finish processing the pending `events`.
  @override
  void onClose() {
    _eventController.close();
    _transitionSubscription?.cancel();
    super.onClose();
  }

  void _bindEventsToStates() {
    _transitionSubscription = transformTransitions(
      transformEvents(
        _eventController.stream,
        (event) => mapEventToState(event).map(
          (nextState) => TransformController(
            currentState: state,
            event: event,
            nextState: nextState,
          ),
        ),
      ),
    ).listen(
      (transition) {
        if (transition.nextState == state && _emitted) return;
        try {
          onTransform(transition);
          emit(transition.nextState);
        } catch (error, stackTrace) {
          onError(error, stackTrace);
        }
      },
      onError: onError,
    );
  }
}

/// A [StateController] is similar to [Controller] but has no notion of events
/// and relies on methods to [emit] new states.
///
/// Every [StateController] requires an initial state which will be the
/// state of the [StateController] before [emit] has been called.
///
/// The current state of a [StateController] can be accessed via the [state] getter.
///
/// ```dart
/// class CounterController extends StateController<int> {
///   CounterController() : super(0);
///
///   void increment() => emit(state + 1);
/// }
/// ```
abstract class StateController<State> extends BaseController<State> {
  StateController(State initialState) : super(initialState);
}

/// An interface for the core functionality implemented by
/// both [Controller] and [StateController].
abstract class BaseController<State> extends StateBase<State> {
  BaseController(State initialState) : super(initialState) {
    // ignore: invalid_use_of_protected_member
    Controller.observer.onCreate(this);
  }

  // ignore: close_sinks
  StreamController<State>? __stateController;
  StreamController<State> get _stateController {
    return __stateController ??= StreamController<State>.broadcast();
  }

  bool _emitted = false;

  /// The current state stream.
  Stream<State> get stream => _stateController.stream;

  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the instance has been closed or if the
  /// [state] being emitted is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the instance.
  void emit(State state) {
    if (_stateController.isClosed) return;
    if (state == _state && _emitted) return;
    onChange(StateChange<State>(currentState: this.state, nextState: state));
    _state = state;
    _stateController.add(_state);
    _emitted = true;
  }

  /// Called whenever a [change] occurs with the given [change].
  /// A [change] occurs when a new `state` is emitted.
  /// [onChange] is called before the `state` of the `StateController` is updated.
  /// [onChange] is a great spot to add logging/analytics for a specific `StateController`.
  ///
  /// **Note: `super.onChange` should always be called first.**
  /// ```dart
  /// @override
  /// void onChange(StateChange change) {
  ///   // Always call super.onChange with the current change
  ///   super.onChange(change);
  ///
  ///   // Custom onChange logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [ObserverController] for observing [StateController] behavior globally.
  @mustCallSuper
  void onChange(StateChange<State> change) {
    // ignore: invalid_use_of_protected_member
    Controller.observer.onChange(this, change);
  }

  /// Reports an [error] which triggers [onError] with an optional [StackTrace].
  @mustCallSuper
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  /// Called whenever an [error] occurs and notifies [controllerObserver.onError].
  ///
  /// In debug mode, [onError] throws a [ControllerUnhandledErrorException] for
  /// improved visibility.
  ///
  /// In release mode, [onError] does not throw and will instead only report
  /// the error to [ObserverController.onError].
  ///
  /// **Note: `super.onError` should always be called last.**
  /// ```dart
  /// @override
  /// void onError(Object error, StackTrace stackTrace) {
  ///   // Custom onError logic goes here
  ///
  ///   // Always call super.onError with the current error and stackTrace
  ///   super.onError(error, stackTrace);
  /// }
  /// ```
  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    Controller.observer.onError(this, error, stackTrace);
    assert(() {
      throw ControllerUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Closes the instance.
  /// This method should be called when the instance is no longer needed.
  /// Once [onClose] is called, the instance can no longer be used.
  @override
  @mustCallSuper
  void onClose() {
    // ignore: invalid_use_of_protected_member
    Controller.observer.onClose(this);
    _stateController.close();
    super.onClose();
  }
}

/// An interface that extends all functionalities of
/// [GetxController] and implemented by [BaseController].
abstract class StateBase<State> extends GetxController {
  StateBase(this._state) {
    _state = _state;
  }

  final State _state;

  /// The current [rxState].
  late final rxState = Rx<State>(_state);

  /// The current [state].
  State get state => rxState.value;
  
  set _state(State value) => rxState.value = value;
}
