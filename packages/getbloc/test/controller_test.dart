import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pedantic/pedantic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'controllers/controllers.dart';

class MockObserverController extends Mock implements ObserverController {}

class FakeBaseController<S> extends Fake implements BaseController<S> {}

void main() {
  group('Controller Tests', () {
    group('Simple Controller', () {
      late SimpleController simpleController;
      late MockObserverController observer;

      setUp(() {
        simpleController = SimpleController();
        observer = MockObserverController();
        Controller.observer = observer;
      });

      test('triggers onCreate on observer when instantiated', () {
        final controller = SimpleController();
        // ignore: invalid_use_of_protected_member
        verify(() => observer.onCreate(controller)).called(1);
      });

      test('triggers onClose on observer when closed', () async {
        final controller = SimpleController();
        await controller.onClose();
        // ignore: invalid_use_of_protected_member
        verify(() => observer.onClose(controller)).called(1);
      });

      test('close does not emit new states over the state stream', () async {
        final expectedStates = [emitsDone];

        unawaited(
            expectLater(simpleController.stream, emitsInOrder(expectedStates)));

        await simpleController.onClose();
      });

      test('state returns correct value initially', () {
        expect(simpleController.state, '');
      });

      test('should map single event to correct state', () {
        final expectedStates = ['data', emitsDone];

        expectLater(
          simpleController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              simpleController,
              const TransformController<dynamic, String>(
                currentState: '',
                event: 'event',
                nextState: 'data',
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              simpleController,
              const StateChange<String>(currentState: '', nextState: 'data'),
            ),
          ).called(1);
          expect(simpleController.state, 'data');
        });

        simpleController
          ..add('event')
          ..onClose();
      });

      test('should map multiple events to correct states', () {
        final expectedStates = ['data', emitsDone];

        expectLater(
          simpleController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              simpleController,
              const TransformController<dynamic, String>(
                currentState: '',
                event: 'event1',
                nextState: 'data',
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              simpleController,
              const StateChange<String>(currentState: '', nextState: 'data'),
            ),
          ).called(1);
          expect(simpleController.state, 'data');
        });

        simpleController
          ..add('event1')
          ..add('event2')
          ..add('event3')
          ..onClose();
      });

      test('is a broadcast stream', () {
        final expectedStates = ['data', emitsDone];

        expect(simpleController.stream.isBroadcast, isTrue);
        expectLater(simpleController.stream, emitsInOrder(expectedStates));
        expectLater(simpleController.stream, emitsInOrder(expectedStates));

        simpleController
          ..add('event')
          ..onClose();
      });

      test('multiple subscribers receive the latest state', () {
        final expectedStates = const <String>['data'];

        expectLater(simpleController.stream, emitsInOrder(expectedStates));
        expectLater(simpleController.stream, emitsInOrder(expectedStates));
        expectLater(simpleController.stream, emitsInOrder(expectedStates));

        simpleController.add('event');
      });
    });

    group('Complex Controller', () {
      late ComplexController complexController;
      late MockObserverController observer;

      setUp(() {
        complexController = ComplexController();
        observer = MockObserverController();
        Controller.observer = observer;
      });

      test('close does not emit new states over the state stream', () async {
        final expectedStates = [emitsDone];

        unawaited(
          expectLater(complexController.stream, emitsInOrder(expectedStates)),
        );

        await complexController.onClose();
      });

      test('state returns correct value initially', () {
        expect(complexController.state, ComplexStateA());
      });

      test('should map single event to correct state', () {
        final expectedStates = [ComplexStateB()];

        expectLater(
          complexController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              complexController,
              TransformController<ComplexEvent, ComplexState>(
                currentState: ComplexStateA(),
                event: ComplexEventB(),
                nextState: ComplexStateB(),
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              complexController,
              StateChange<ComplexState>(
                currentState: ComplexStateA(),
                nextState: ComplexStateB(),
              ),
            ),
          ).called(1);
          expect(complexController.state, ComplexStateB());
        });

        complexController.add(ComplexEventB());
      });

      test('should map multiple events to correct states', () async {
        final expectedStates = [
          ComplexStateB(),
          ComplexStateD(),
          ComplexStateA(),
          ComplexStateC(),
        ];

        unawaited(
          expectLater(complexController.stream, emitsInOrder(expectedStates)),
        );

        complexController.add(ComplexEventA());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        complexController.add(ComplexEventB());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        complexController.add(ComplexEventC());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        complexController.add(ComplexEventD());
        await Future<void>.delayed(const Duration(milliseconds: 200));
        complexController..add(ComplexEventC())..add(ComplexEventA());
        await Future<void>.delayed(const Duration(milliseconds: 120));
        complexController.add(ComplexEventC());
      });

      test('is a broadcast stream', () {
        final expectedStates = [ComplexStateB()];

        expect(complexController.stream.isBroadcast, isTrue);
        expectLater(complexController.stream, emitsInOrder(expectedStates));
        expectLater(complexController.stream, emitsInOrder(expectedStates));

        complexController.add(ComplexEventB());
      });

      test('multiple subscribers receive the latest state', () {
        final expected = <ComplexState>[ComplexStateB()];

        expectLater(complexController.stream, emitsInOrder(expected));
        expectLater(complexController.stream, emitsInOrder(expected));
        expectLater(complexController.stream, emitsInOrder(expected));

        complexController.add(ComplexEventB());
      });
    });

    group('CounterController', () {
      late CounterController counterController;
      late MockObserverController observer;
      late List<String> transitions;
      late List<CounterEvent> events;

      setUp(() {
        events = [];
        transitions = [];
        counterController = CounterController(
          onEventCallback: events.add,
          onTransformCallback: (transition) {
            transitions.add(transition.toString());
          },
        );
        observer = MockObserverController();
        Controller.observer = observer;
      });

      test('state returns correct value initially', () {
        expect(counterController.state, 0);
        expect(events.isEmpty, true);
        expect(transitions.isEmpty, true);
      });

      test('single Increment event updates state to 1', () {
        final expectedStates = [1, emitsDone];
        final expectedTransitions = [
          '''Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }'''
        ];

        expectLater(
          counterController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expectLater(transitions, expectedTransitions);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              counterController,
              const TransformController<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterController,
              const StateChange<int>(currentState: 0, nextState: 1),
            ),
          ).called(1);
          expect(counterController.state, 1);
        });

        counterController
          ..add(CounterEvent.increment)
          ..onClose();
      });

      test('multiple Increment event updates state to 3', () {
        final expectedStates = [1, 2, 3, emitsDone];
        final expectedTransitions = [
          '''Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }''',
          '''Transition { currentState: 1, event: CounterEvent.increment, nextState: 2 }''',
          '''Transition { currentState: 2, event: CounterEvent.increment, nextState: 3 }''',
        ];

        expectLater(
          counterController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              counterController,
              const TransformController<CounterEvent, int>(
                currentState: 0,
                event: CounterEvent.increment,
                nextState: 1,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterController,
              const StateChange<int>(currentState: 0, nextState: 1),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              counterController,
              const TransformController<CounterEvent, int>(
                currentState: 1,
                event: CounterEvent.increment,
                nextState: 2,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterController,
              const StateChange<int>(currentState: 1, nextState: 2),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              counterController,
              const TransformController<CounterEvent, int>(
                currentState: 2,
                event: CounterEvent.increment,
                nextState: 3,
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              counterController,
              const StateChange<int>(currentState: 2, nextState: 3),
            ),
          ).called(1);
        });

        counterController
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment)
          ..onClose();
      });

      test('is a broadcast stream', () {
        final expectedStates = [1, emitsDone];

        expect(counterController.stream.isBroadcast, isTrue);
        expectLater(counterController.stream, emitsInOrder(expectedStates));
        expectLater(counterController.stream, emitsInOrder(expectedStates));

        counterController
          ..add(CounterEvent.increment)
          ..onClose();
      });

      test('multiple subscribers receive the latest state', () {
        const expected = <int>[1];

        expectLater(counterController.stream, emitsInOrder(expected));
        expectLater(counterController.stream, emitsInOrder(expected));
        expectLater(counterController.stream, emitsInOrder(expected));

        counterController.add(CounterEvent.increment);
      });
    });

    group('Async Controller', () {
      late AsyncController asyncController;
      late MockObserverController observer;

      setUpAll(() {
        registerFallbackValue<BaseController<dynamic>>(
            FakeBaseController<dynamic>());
        registerFallbackValue<StackTrace>(StackTrace.empty);
      });

      setUp(() {
        asyncController = AsyncController();
        observer = MockObserverController();
        Controller.observer = observer;
      });

      test('close does not emit new states over the state stream', () async {
        final expectedStates = [emitsDone];

        unawaited(
            expectLater(asyncController.stream, emitsInOrder(expectedStates)));

        await asyncController.onClose();
      });

      test(
          'close while events are pending finishes processing pending events '
          'and does not trigger onError', () async {
        final expectedStates = <AsyncState>[
          AsyncState.initial().copyWith(isLoading: true),
          AsyncState.initial().copyWith(isSuccess: true),
        ];
        final states = <AsyncState>[];

        asyncController
          ..stream.listen(states.add)
          ..add(AsyncEvent());

        await asyncController.onClose();

        expect(states, expectedStates);
        // ignore: invalid_use_of_protected_member
        verifyNever(() => observer.onError(any(), any(), any()));
      });

      test('state returns correct value initially', () {
        expect(asyncController.state, AsyncState.initial());
      });

      test('should map single event to correct state', () {
        final expectedStates = [
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];

        expectLater(
          asyncController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              asyncController,
              TransformController<AsyncEvent, AsyncState>(
                currentState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              asyncController,
              StateChange<AsyncState>(
                currentState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: false,
                ),
                nextState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onTransform(
              asyncController,
              TransformController<AsyncEvent, AsyncState>(
                currentState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
                event: AsyncEvent(),
                nextState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: true,
                ),
              ),
            ),
          ).called(1);
          verify(
            // ignore: invalid_use_of_protected_member
            () => observer.onChange(
              asyncController,
              StateChange<AsyncState>(
                currentState: AsyncState(
                  isLoading: true,
                  hasError: false,
                  isSuccess: false,
                ),
                nextState: AsyncState(
                  isLoading: false,
                  hasError: false,
                  isSuccess: true,
                ),
              ),
            ),
          ).called(1);
          expect(
            asyncController.state,
            AsyncState(
              isLoading: false,
              hasError: false,
              isSuccess: true,
            ),
          );
        });

        asyncController
          ..add(AsyncEvent())
          ..onClose();
      });

      test('is a broadcast stream', () {
        final expectedStates = [
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
          emitsDone,
        ];

        expect(asyncController.stream.isBroadcast, isTrue);
        expectLater(asyncController.stream, emitsInOrder(expectedStates));
        expectLater(asyncController.stream, emitsInOrder(expectedStates));

        asyncController
          ..add(AsyncEvent())
          ..onClose();
      });

      test('multiple subscribers receive the latest state', () {
        final expected = <AsyncState>[
          AsyncState(isLoading: true, hasError: false, isSuccess: false),
          AsyncState(isLoading: false, hasError: false, isSuccess: true),
        ];

        expectLater(asyncController.stream, emitsInOrder(expected));
        expectLater(asyncController.stream, emitsInOrder(expected));
        expectLater(asyncController.stream, emitsInOrder(expected));

        asyncController.add(AsyncEvent());
      });
    });

    group('flatMap', () {
      test('maintains correct transition composition', () {
        final expectedTransitions = <TransformController<CounterEvent, int>>[
          const TransformController(
            currentState: 0,
            event: CounterEvent.decrement,
            nextState: -1,
          ),
          const TransformController(
            currentState: -1,
            event: CounterEvent.increment,
            nextState: 0,
          ),
        ];

        final expectedStates = [-1, 0, emitsDone];
        final transitions = <TransformController<CounterEvent, int>>[];
        final flatMapController = FlatMapController(
          onTransformCallback: transitions.add,
        );

        expectLater(
          flatMapController.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
        });
        flatMapController
          ..add(CounterEvent.decrement)
          ..add(CounterEvent.increment)
          ..onClose();
      });
    });

    group('mergeController', () {
      test('maintains correct transition composition', () {
        final expectedTransitions = <TransformController<CounterEvent, int>>[
          const TransformController(
            currentState: 0,
            event: CounterEvent.increment,
            nextState: 1,
          ),
          const TransformController(
            currentState: 1,
            event: CounterEvent.decrement,
            nextState: 0,
          ),
          const TransformController(
            currentState: 0,
            event: CounterEvent.decrement,
            nextState: -1,
          ),
        ];
        final expectedStates = [1, 0, -1, emitsDone];
        final transitions = <TransformController<CounterEvent, int>>[];

        final controller = MergeController(
          onTransformCallback: transitions.add,
        );

        expectLater(
          controller.stream,
          emitsInOrder(expectedStates),
        ).then((dynamic _) {
          expect(transitions, expectedTransitions);
        });
        controller
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment)
          ..add(CounterEvent.decrement)
          ..add(CounterEvent.decrement)
          ..onClose();
      });
    });

    group('SeededController', () {
      test('does not emit repeated states', () {
        final seededController =
            SeededController(seed: 0, states: [1, 2, 1, 1]);
        final expectedStates = [1, 2, 1, emitsDone];

        expectLater(seededController.stream, emitsInOrder(expectedStates));

        seededController
          ..add('event')
          ..onClose();
      });

      test('can emit initial state only once', () {
        final seededController = SeededController(seed: 0, states: [0, 0]);
        final expectedStates = [0, emitsDone];

        expectLater(seededController.stream, emitsInOrder(expectedStates));

        seededController
          ..add('event')
          ..onClose();
      });

      test(
          'can emit initial state and '
          'continue emitting distinct states', () {
        final seededController = SeededController(seed: 0, states: [0, 0, 1]);
        final expectedStates = [0, 1, emitsDone];

        expectLater(seededController.stream, emitsInOrder(expectedStates));

        seededController
          ..add('event')
          ..onClose();
      });

      test('discards subsequent duplicate states (distinct events)', () {
        final seededController = SeededController(seed: 0, states: [1, 1]);
        final expectedStates = [1, emitsDone];

        expectLater(seededController.stream, emitsInOrder(expectedStates));

        seededController
          ..add('eventA')
          ..add('eventB')
          ..add('eventC')
          ..onClose();
      });

      test('discards subsequent duplicate states (same event)', () {
        final seededController = SeededController(seed: 0, states: [1, 1]);
        final expectedStates = [1, emitsDone];

        expectLater(seededController.stream, emitsInOrder(expectedStates));

        seededController
          ..add('event')
          ..add('event')
          ..add('event')
          ..onClose();
      });
    });

    group('Exception', () {
      test('does not break stream', () {
        runZonedGuarded(() {
          final expectedStates = [-1, emitsDone];
          final counterController = CounterExceptionController();

          expectLater(counterController.stream, emitsInOrder(expectedStates));

          counterController
            ..add(CounterEvent.increment)
            ..add(CounterEvent.decrement)
            ..onClose();
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as ControllerUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'CounterExceptionController\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('addError triggers onError', () async {
        final expectedError = Exception('fatal exception');

        runZonedGuarded(() {
          OnExceptionController(
            exception: expectedError,
            onErrorCallback: (Object _, StackTrace __) {},
          )..addError(expectedError, StackTrace.current);
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as ControllerUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'OnExceptionController\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('triggers onError from mapEventToState', () {
        runZonedGuarded(() {
          final exception = Exception('fatal exception');
          Object? expectedError;
          StackTrace? expectedStacktrace;

          final onExceptionController = OnExceptionController(
              exception: exception,
              onErrorCallback: (Object error, StackTrace stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              });

          expectLater(
            onExceptionController.stream,
            emitsInOrder(<Matcher>[emitsDone]),
          ).then((dynamic _) {
            expect(expectedError, exception);
            expect(expectedStacktrace, isNotNull);
            expect(expectedStacktrace, isNot(StackTrace.empty));
          });

          onExceptionController
            ..add(CounterEvent.increment)
            ..onClose();
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as ControllerUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'OnExceptionController\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('triggers onError from onEvent', () {
        runZonedGuarded(() {
          final exception = Exception('fatal exception');

          OnEventErrorController(exception: exception)
            ..add(CounterEvent.increment)
            ..onClose();
        }, (Object error, StackTrace stackTrace) {
          expect(
            (error as ControllerUnhandledErrorException).toString(),
            contains(
              'Unhandled error Exception: fatal exception occurred '
              'in Instance of \'OnEventErrorController\'.',
            ),
          );
          expect(stackTrace, isNotNull);
          expect(stackTrace, isNot(StackTrace.empty));
        });
      });

      test('does not trigger onError from add', () {
        runZonedGuarded(() {
          Object? capturedError;
          StackTrace? capturedStacktrace;
          final counterController = CounterController(
            onErrorCallback: (error, stackTrace) {
              capturedError = error;
              capturedStacktrace = stackTrace;
            },
          );

          expectLater(
            counterController.stream,
            emitsInOrder(<Matcher>[emitsDone]),
          ).then((dynamic _) {
            expect(capturedError, isNull);
            expect(capturedStacktrace, isNull);
          });

          counterController
            ..onClose()
            ..add(CounterEvent.increment);
        }, (Object _, StackTrace __) {
          fail(
              'should not throw when add is called after controller is closed');
        });
      });
    });

    group('Error', () {
      test('does not break stream', () {
        runZonedGuarded(
          () {
            final expectedStates = [-1, emitsDone];
            final counterController = CounterErrorController();

            expectLater(counterController.stream, emitsInOrder(expectedStates));

            counterController
              ..add(CounterEvent.increment)
              ..add(CounterEvent.decrement)
              ..onClose();
          },
          (Object _, StackTrace __) {},
        );
      });

      test('triggers onError from mapEventToState', () {
        runZonedGuarded(
          () {
            final error = Error();
            Object? expectedError;
            StackTrace? expectedStacktrace;

            final onErrorController = OnErrorController(
              error: error,
              onErrorCallback: (Object error, StackTrace stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              },
            );

            expectLater(
              onErrorController.stream,
              emitsInOrder(<Matcher>[emitsDone]),
            ).then((dynamic _) {
              expect(expectedError, error);
              expect(expectedStacktrace, isNotNull);
            });

            onErrorController
              ..add(CounterEvent.increment)
              ..onClose();
          },
          (Object _, StackTrace __) {},
        );
      });

      test('triggers onError from onTransform', () {
        runZonedGuarded(
          () {
            final error = Error();
            Object? expectedError;
            StackTrace? expectedStacktrace;

            final onTransformErrorController = OnTransformErrorController(
              error: error,
              onErrorCallback: (Object error, StackTrace stackTrace) {
                expectedError = error;
                expectedStacktrace = stackTrace;
              },
            );

            expectLater(
              onTransformErrorController.stream,
              emitsInOrder(<Matcher>[emitsDone]),
            ).then((dynamic _) {
              expect(expectedError, error);
              expect(expectedStacktrace, isNotNull);
              expect(onTransformErrorController.state, 0);
            });

            onTransformErrorController
              ..add(CounterEvent.increment)
              ..onClose();
          },
          (Object _, StackTrace __) {},
        );
      });
    });

    group('emit', () {
      test('updates the state', () async {
        final counterController = CounterController();
        unawaited(
          expectLater(counterController.stream, emitsInOrder(const <int>[42])),
        );
        counterController.emit(42);
        expect(counterController.state, 42);
        await counterController.onClose();
      });
    });

    group('close', () {
      test('emits done (sync)', () {
        final controller = CounterController()..onClose();
        expect(controller.stream, emitsDone);
      });

      test('emits done (async)', () async {
        final controller = CounterController();
        await controller.onClose();
        expect(controller.stream, emitsDone);
      });
    });
  });
}
