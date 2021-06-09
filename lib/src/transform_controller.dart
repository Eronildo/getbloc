import 'package:meta/meta.dart';

/// {@template state_change}
/// A [StateChange] represents the change from one [State] to another.
/// A [StateChange] consists of the [currentState] and [nextState].
/// {@endtemplate}
@immutable
class StateChange<State> {
  /// {@macro state_change}
  const StateChange({required this.currentState, required this.nextState});

  /// The current [State] at the time of the [StateChange].
  final State currentState;

  /// The next [State] at the time of the [StateChange].
  final State nextState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateChange<State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState;

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Change { currentState: $currentState, nextState: $nextState }';
  }
}

/// {@template transform_controller}
/// A [TransformController] is the change from one state to another.
/// Consists of the [currentState], an [event], and the [nextState].
/// {@endtemplate}
@immutable
class TransformController<Event, State> extends StateChange<State> {
  /// {@macro transform_controller}
  const TransformController({
    required State currentState,
    required this.event,
    required State nextState,
  }) : super(currentState: currentState, nextState: nextState);

  /// The [Event] which triggered the current [TransformController].
  final Event event;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransformController<Event, State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          event == other.event &&
          nextState == other.nextState;

  @override
  int get hashCode {
    return currentState.hashCode ^ event.hashCode ^ nextState.hashCode;
  }

  @override
  String toString() {
    return '''Transition { currentState: $currentState, event: $event, nextState: $nextState }''';
  }
}
