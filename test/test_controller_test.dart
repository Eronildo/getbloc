import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'controllers/controllers.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  group('testController', () {
    group('CounterController', () {
      testController<CounterController, int>(
        'supports matchers (contains)',
        build: () => CounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => contains(1),
      );

      testController<CounterController, int>(
        'supports matchers (containsAll)',
        build: () => CounterController(),
        act: (controller) => controller
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => containsAll(<int>[2, 1]),
      );

      testController<CounterController, int>(
        'supports matchers (containsAllInOrder)',
        build: () => CounterController(),
        act: (controller) => controller
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => containsAllInOrder(<int>[1, 2]),
      );

      testController<CounterController, int>(
        'emits [] when nothing is added',
        build: () => CounterController(),
        expect: () => const <int>[],
      );

      testController<CounterController, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => CounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
      );

      testController<CounterController, int>(
        'emits [1] when CounterEvent.increment is added with async act',
        build: () => CounterController(),
        act: (controller) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          controller.add(CounterEvent.increment);
        },
        expect: () => const <int>[1],
      );

      testController<CounterController, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple times '
        'with async act',
        build: () => CounterController(),
        act: (controller) async {
          controller.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          controller.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2],
      );

      testController<CounterController, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () => CounterController(),
        act: (controller) {
          controller..add(CounterEvent.increment)..add(CounterEvent.increment);
        },
        skip: 1,
        expect: () => const <int>[2],
      );

      testController<CounterController, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => CounterController()..emit(10),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[11],
      );

      testController<CounterController, int>(
        'emits [11] when CounterEvent.increment is added and seed 10',
        build: () => CounterController(),
        seed: () => 10,
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[11],
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError = '''Expected: [2]
  Actual: [1]
   Which: at location [0] is <1> instead of <2>
''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(internalControllerTest<CounterController, int>(
            build: () => CounterController(),
            act: (controller) => controller.add(CounterEvent.increment),
            expect: () => const <int>[2],
          ).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });
    });

    /*group('AsyncCounterController', () {
      testController<AsyncCounterController, int>(
        'emits [] when nothing is added',
        build: () => AsyncCounterController(),
        expect: () => const <int>[],
      );

      testController<AsyncCounterController, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => AsyncCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
      );

      testController<AsyncCounterController, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple'
        'times with async act',
        build: () => AsyncCounterController(),
        act: (controller) async {
          controller.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          controller.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2],
      );

      testController<AsyncCounterController, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () => AsyncCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
      );

      testController<AsyncCounterController, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => AsyncCounterController()..emit(10),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[11],
      );
    });

    group('DebounceCounterController', () {
      testController<DebounceCounterController, int>(
        'emits [] when nothing is added',
        build: () => DebounceCounterController(),
        expect: () => const <int>[],
      );

      testController<DebounceCounterController, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => DebounceCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: () => const <int>[1],
      );

      testController<DebounceCounterController, int>(
        'emits [2] when CounterEvent.increment '
        'is added twice and skip: 1',
        build: () => DebounceCounterController(),
        act: (controller) async {
          controller.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 305));
          controller.add(CounterEvent.increment);
        },
        skip: 1,
        wait: const Duration(milliseconds: 300),
        expect: () => const <int>[2],
      );

      testController<DebounceCounterController, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => DebounceCounterController()..emit(10),
        act: (controller) => controller.add(CounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: () => const <int>[11],
      );
    });

    group('InstanceEmitController', () {
      testController<InstantEmitController, int>(
        'emits [1] when nothing is added',
        build: () => InstantEmitController(),
        expect: () => const <int>[1],
      );

      testController<InstantEmitController, int>(
        'emits [1, 2] when CounterEvent.increment is added',
        build: () => InstantEmitController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
      );

      testController<InstantEmitController, int>(
        'emits [1, 2, 3] when CounterEvent.increment is called'
        'multiple times with async act',
        build: () => InstantEmitController(),
        act: (controller) async {
          controller.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          controller.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2, 3],
      );

      testController<InstantEmitController, int>(
        'emits [3] when CounterEvent.increment is added twice and skip: 2',
        build: () => InstantEmitController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 2,
        expect: () => const <int>[3],
      );

      testController<InstantEmitController, int>(
        'emits [11, 12] when CounterEvent.increment is added and emitted 10',
        build: () => InstantEmitController()..emit(10),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[11, 12],
      );
    });

    group('MultiCounterController', () {
      testController<MultiCounterController, int>(
        'emits [] when nothing is added',
        build: () => MultiCounterController(),
        expect: () => const <int>[],
      );

      testController<MultiCounterController, int>(
        'emits [1, 2] when CounterEvent.increment is added',
        build: () => MultiCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
      );

      testController<MultiCounterController, int>(
        'emits [1, 2, 3, 4] when CounterEvent.increment is called'
        'multiple times with async act',
        build: () => MultiCounterController(),
        act: (controller) async {
          controller.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          controller.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2, 3, 4],
      );

      testController<MultiCounterController, int>(
        'emits [4] when CounterEvent.increment is added twice and skip: 3',
        build: () => MultiCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 3,
        expect: () => const <int>[4],
      );

      testController<MultiCounterController, int>(
        'emits [11, 12] when CounterEvent.increment is added and emitted 10',
        build: () => MultiCounterController()..emit(10),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[11, 12],
      );
    });*/

    group('ComplexTestController', () {
      testController<ComplexTestController, ComplexTestState>(
        'emits [] when nothing is added',
        build: () => ComplexTestController(),
        expect: () => const <ComplexTestState>[],
      );

      testController<ComplexTestController, ComplexTestState>(
        'emits [ComplexTestStateB] when ComplexTestEventB is added',
        build: () => ComplexTestController(),
        act: (controller) => controller.add(ComplexTestEventB()),
        expect: () => <Matcher>[isA<ComplexTestStateB>()],
      );

      testController<ComplexTestController, ComplexTestState>(
        'emits [ComplexTestStateA] when [ComplexTestEventB, ComplexTestEventA] '
        'is added and skip: 1',
        build: () => ComplexTestController(),
        act: (controller) =>
            controller..add(ComplexTestEventB())..add(ComplexTestEventA()),
        skip: 1,
        expect: () => <Matcher>[isA<ComplexTestStateA>()],
      );
    });
    /*group('ErrorCounterController', () {
      testController<ErrorCounterController, int>(
        'emits [] when nothing is added',
        build: () => ErrorCounterController(),
        expect: () => const <int>[],
      );

      testController<ErrorCounterController, int>(
        'emits [2] when increment is added twice and skip: 1',
        build: () => ErrorCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
      );

      testController<ErrorCounterController, int>(
        'emits [1] when increment is added',
        build: () => ErrorCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
      );

      testController<ErrorCounterController, int>(
        'throws ErrorCounterControllerException when increment is added',
        build: () => ErrorCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        errors: () => <Matcher>[isA<ErrorCounterControllerError>()],
      );

      testController<ErrorCounterController, int>(
        'emits [1] and throws ErrorCounterControllerError '
        'when increment is added',
        build: () => ErrorCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
        errors: () => <Matcher>[isA<ErrorCounterControllerError>()],
      );

      testController<ErrorCounterController, int>(
        'emits [1, 2] when increment is added twice',
        build: () => ErrorCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
      );

      testController<ErrorCounterController, int>(
        'throws two ErrorCounterControllerErrors '
        'when increment is added twice',
        build: () => ErrorCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        errors: () => <Matcher>[
          isA<ErrorCounterControllerError>(),
          isA<ErrorCounterControllerError>(),
        ],
      );

      testController<ErrorCounterController, int>(
        'emits [1, 2] and throws two ErrorCounterControllerErrors '
        'when increment is added twice',
        build: () => ErrorCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
        errors: () => <Matcher>[
          isA<ErrorCounterControllerError>(),
          isA<ErrorCounterControllerError>(),
        ],
      );
    });

    group('ExceptionCounterController', () {
      testController<ExceptionCounterController, int>(
        'emits [] when nothing is added',
        build: () => ExceptionCounterController(),
        expect: () => const <int>[],
      );

      testController<ExceptionCounterController, int>(
        'emits [2] when increment is added twice and skip: 1',
        build: () => ExceptionCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
      );

      testController<ExceptionCounterController, int>(
        'emits [1] when increment is added',
        build: () => ExceptionCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
      );

      testController<ExceptionCounterController, int>(
        'throws ExceptionCounterControllerException when increment is added',
        build: () => ExceptionCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        errors: () => <Matcher>[isA<ExceptionCounterControllerException>()],
      );

      testController<ExceptionCounterController, int>(
        'emits [1] and throws ExceptionCounterControllerException '
        'when increment is added',
        build: () => ExceptionCounterController(),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
        errors: () => <Matcher>[isA<ExceptionCounterControllerException>()],
      );

      testController<ExceptionCounterController, int>(
        'emits [1, 2] when increment is added twice',
        build: () => ExceptionCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
      );

      testController<ExceptionCounterController, int>(
        'throws two ExceptionCounterControllerExceptions '
        'when increment is added twice',
        build: () => ExceptionCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        errors: () => <Matcher>[
          isA<ExceptionCounterControllerException>(),
          isA<ExceptionCounterControllerException>(),
        ],
      );

      testController<ExceptionCounterController, int>(
        'emits [1, 2] and throws two ExceptionCounterControllerException '
        'when increment is added twice',
        build: () => ExceptionCounterController(),
        act: (controller) =>
            controller..add(CounterEvent.increment)..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
        errors: () => <Matcher>[
          isA<ExceptionCounterControllerException>(),
          isA<ExceptionCounterControllerException>(),
        ],
      );
    });*/

    group('SideEffectCounterController', () {
      late Repository repository;

      setUp(() {
        repository = MockRepository();
        when(() => repository.sideEffect()).thenReturn(null);
      });

      testController<SideEffectCounterController, int>(
        'emits [] when nothing is added',
        build: () => SideEffectCounterController(repository),
        expect: () => const <int>[],
      );

      testController<SideEffectCounterController, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => SideEffectCounterController(repository),
        act: (controller) => controller.add(CounterEvent.increment),
        expect: () => const <int>[1],
        verify: (_) {
          verify(() => repository.sideEffect()).called(1);
        },
      );

      testController<SideEffectCounterController, int>(
        'emits [2] when CounterEvent.increment '
        'is added twice and skip: 1',
        build: () => SideEffectCounterController(repository),
        act: (controller) => controller
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
      );

      testController<SideEffectCounterController, int>(
        'does not require an expect',
        build: () => SideEffectCounterController(repository),
        act: (controller) => controller.add(CounterEvent.increment),
        verify: (_) {
          verify(() => repository.sideEffect()).called(1);
        },
      );

      testController<SideEffectCounterController, int>(
        'async verify',
        build: () => SideEffectCounterController(repository),
        act: (controller) => controller.add(CounterEvent.increment),
        verify: (_) async {
          await Future<void>.delayed(Duration.zero);
          verify(() => repository.sideEffect()).called(1);
        },
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError =
            '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(internalControllerTest<SideEffectCounterController, int>(
            build: () => SideEffectCounterController(repository),
            act: (controller) => controller.add(CounterEvent.increment),
            verify: (_) {
              verify(() => repository.sideEffect()).called(2);
            },
          ).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError = '''Expected: [Instance of \'ComplexTestStateA\']
  Actual: [Instance of \'ComplexTestStateA\']
   Which: at location [0] is <Instance of \'ComplexTestStateA\'> instead of <Instance of \'ComplexTestStateA\'>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the internalControllerTest rather than concrete state instances.\n''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(
              internalControllerTest<ComplexTestController, ComplexTestState>(
            build: () => ComplexTestController(),
            act: (controller) => controller.add(ComplexTestEventA()),
            expect: () => <ComplexTestState>[ComplexTestStateA()],
          ).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });
    });
  });
}
