import 'dart:async';

import 'package:meta/meta.dart';
import 'package:getbloc/getbloc.dart';
import 'package:test/test.dart' as test;

/// Creates a new `controller`-specific test case with the given [description].
/// [testController] will handle asserting that the `controller` emits the [expect]ed
/// states (in order) after [act] is executed.
/// [testController] also handles ensuring that no additional states are emitted
/// by closing the `controller` stream before evaluating the [expect]ation.
///
/// [build] should be used for all `controller` initialization and preparation
/// and must return the `controller` under test.
///
/// [seed] is an optional `Function` that returns a state
/// which will be used to seed the `controller` before [act] is called.
///
/// [act] is an optional callback which will be invoked with the `controller` under
/// test and should be used to interact with the `controller`.
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// [skip] defaults to 0.
///
/// [wait] is an optional `Duration` which can be used to wait for
/// async operations within the `controller` under test such as `debounceTime`.
///
/// [expect] is an optional `Function` that returns a `Matcher` which the `controller`
/// under test is expected to emit after [act] is executed.
///
/// [verify] is an optional callback which is invoked after [expect]
/// and can be used for additional verification/assertions.
/// [verify] is called with the `controller` returned by [build].
///
/// [errors] is an optional `Function` that returns a `Matcher` which the `controller`
/// under test is expected to throw after [act] is executed.
///
/// ```dart
/// testController(
///   'CounterController emits [1] when increment is added',
///   build: () => CounterController(),
///   act: (controller) => controller.add(CounterEvent.increment),
///   expect: () => [1],
/// );
/// ```
///
/// [testController] can optionally be used with a seeded state.
///
/// ```dart
/// testController(
///   'CounterController emits [10] when seeded with 9',
///   build: () => CounterController(),
///   seed: () => 9,
///   act: (controller) => controller.add(CounterEvent.increment),
///   expect: () => [10],
/// );
/// ```
///
/// [testController] can also be used to [skip] any number of emitted states
/// before asserting against the expected states.
/// [skip] defaults to 0.
///
/// ```dart
/// testController(
///   'CounterController emits [2] when increment is added twice',
///   build: () => CounterController(),
///   act: (controller) {
///     controller
///       ..add(CounterEvent.increment)
///       ..add(CounterEvent.increment);
///   },
///   skip: 1,
///   expect: () => [2],
/// );
/// ```
///
/// [testController] can also be used to wait for async operations
/// by optionally providing a `Duration` to [wait].
///
/// ```dart
/// testController(
///   'CounterController emits [1] when increment is added',
///   build: () => CounterController(),
///   act: (controller) => controller.add(CounterEvent.increment),
///   wait: const Duration(milliseconds: 300),
///   expect: () => [1],
/// );
/// ```
///
/// [testController] can also be used to [verify] internal controller functionality.
///
/// ```dart
/// testController(
///   'CounterController emits [1] when increment is added',
///   build: () => CounterController(),
///   act: (controller) => controller.add(CounterEvent.increment),
///   expect: () => [1],
///   verify: (_) {
///     verify(() => repository.someMethod(any())).called(1);
///   }
/// );
/// ```
///
/// **Note:** when using [testController] with state classes which don't override
/// `==` and `hashCode` you can provide an `Iterable` of matchers instead of
/// explicit state instances.
///
/// ```dart
/// testController(
///  'emits [StateB] when EventB is added',
///  build: () => MyController(),
///  act: (controller) => controller.add(EventB()),
///  expect: () => [isA<StateB>()],
/// );
/// ```
@isTest
void testController<C extends BaseController<State>, State>(
  String description, {
  required C Function() build,
  State Function()? seed,
  Function(C controller)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  Function(C controller)? verify,
  dynamic Function()? errors,
}) {
  test.test(description, () async {
    await internalControllerTest<C, State>(
      build: build,
      seed: seed,
      act: act,
      wait: wait,
      skip: skip,
      expect: expect,
      verify: verify,
      errors: errors,
    );
  });
}

/// Internal [testController] runner which is only visible for testing.
/// This should never be used directly -- please use [testController] instead.
@visibleForTesting
Future<void> internalControllerTest<C extends BaseController<State>, State>({
  required C Function() build,
  State Function()? seed,
  Function(C controller)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  Function(C controller)? verify,
  dynamic Function()? errors,
}) async {
  final unhandledErrors = <Object>[];
  var shallowEquality = false;
  await runZonedGuarded(
    () async {
      final states = <State>[];
      final controller = build();
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      if (seed != null) controller.emit(seed());
      final subscription = controller.stream.skip(skip).listen(states.add);
      try {
        await act?.call(controller);
      } catch (error) {
        unhandledErrors.add(
          error is ControllerUnhandledErrorException ? error.error : error,
        );
      }
      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      await controller.onClose();
      if (expect != null) {
        final dynamic expected = expect();
        shallowEquality = '$states' == '$expected';
        test.expect(states, test.wrapMatcher(expected));
      }
      await subscription.cancel();
      await verify?.call(controller);
    },
    (Object error, _) {
      if (error is ControllerUnhandledErrorException) {
        unhandledErrors.add(error.error);
      } else if (shallowEquality && error is test.TestFailure) {
        // ignore: only_throw_errors
        throw test.TestFailure(
          // ignore: leading_newlines_in_multiline_strings
          '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the internalControllerTest rather than concrete state instances.\n''',
        );
      } else {
        // ignore: only_throw_errors
        throw error;
      }
    },
  );
  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}
