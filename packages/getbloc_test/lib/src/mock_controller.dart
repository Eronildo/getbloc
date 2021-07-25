import 'package:getbloc/getbloc.dart';
import 'package:mocktail/mocktail.dart';

/// {@template mock_controller}
/// Extend or mixin this class to mark the implementation as a [MockController].
///
/// A mocked controller implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when].
///
/// _**Note**: It is critical to explicitly provide the event and state
/// types when extending [MockController]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterController extends MockController<CounterEvent, int>
///   implements CounterController {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterController extends MockController implements CounterController {}
/// ```
/// {@endtemplate}
class MockController<E, S> extends _MockBaseController<S>
    implements Controller<E, S> {
  /// {@macro mock_controller}
  MockController() {
    when(() => mapEventToState(any())).thenAnswer((_) => Stream<S>.empty());
    when(() => add(any())).thenReturn(null);
  }
}

/// {@template mock_state_controller}
/// Extend or mixin this class to mark the implementation as a [MockStateController].
///
/// A mocked StateController implements all fields and methods with a default
/// implementation that does not throw a [NoSuchMethodError],
/// and may be further customized at runtime to define how it may behave using
/// [when].
///
/// _**Note**: It is critical to explicitly provide the state
/// types when extending [MockStateController]_.
///
/// **GOOD**
/// ```dart
/// class MockCounterStateController extends MockStateController<int>
///   implements CounterStateController {}
/// ```
///
/// **BAD**
/// ```dart
/// class MockCounterStateController extends MockController implements CounterStateController {}
/// ```
/// {@endtemplate}
class MockStateController<S> extends _MockBaseController<S>
    implements StateController<S> {}

class _MockBaseController<S> extends Mock implements BaseController<S> {
  _MockBaseController() {
    final mockInternalFinalCallback = MockInternalFinalCallback<void>();
    when(mockInternalFinalCallback).thenReturn(null);
    registerFallbackValue<void Function(S)>((S _) {});
    registerFallbackValue<void Function()>(() {});
    when(
      () => stream.listen(
        any(),
        onDone: any(named: 'onDone'),
        onError: any(named: 'onError'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      return Stream<S>.empty().listen(
        invocation.positionalArguments.first as void Function(S data),
        onError: invocation.namedArguments[#onError] as Function?,
        onDone: invocation.namedArguments[#onDone] as void Function()?,
        cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
      );
    });
    when(() => stream).thenAnswer((_) => Stream<S>.empty());
    when(onClose).thenAnswer((_) => Future<void>.value());
    when(() => emit(any())).thenReturn(null);
    // ignore: unnecessary_lambdas
    when(() => onStart()).thenReturn(mockInternalFinalCallback);
    // ignore: unnecessary_lambdas
    when(() => onDelete()).thenReturn(mockInternalFinalCallback);
  }
}

/// A mocked InternalFinalCallback
class MockInternalFinalCallback<T> extends Mock
    implements InternalFinalCallback<T> {}

/// {@template when_controller}
/// Create a stub controller's state response.
///
/// ```dart
/// controller.whenState(InitialState());
/// ```
/// {@endtemplate}
extension whenController<T> on StateBase<T> {
  /// {@macro when_controller}
  void whenState(T state) {
    when(() => this.state).thenReturn(state);
    when(() => rxState).thenReturn(Rx(state));
  }
}
