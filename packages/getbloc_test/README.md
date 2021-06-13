<p align="center">
<img src="https://raw.githubusercontent.com/Eronildo/getbloc/main/docs/assets/getbloc_logo.png" height="100" alt="GetBloc" />
</p>

---

A Dart package that makes testing controllers easy. Built to work with [getbloc](https://pub.dev/packages/getbloc).

---

## Unit Test with testController

**testController** creates a new `controller`-specific test case with the given `description`.
`testController` will handle asserting that the `controller` emits the `expect`ed states (in order) after `act` is executed. `testController` also handles ensuring that no additional states are emitted by closing the `controller` stream before evaluating the `expect`ation.

`build` should be used for all `controller` initialization and preparation and must return the `controller` under test.

`seed` is an optional `Function` that returns a state which will be used to seed the `controller` before `act` is called.

`act` is an optional callback which will be invoked with the `controller` under test and should be used to interact with the `controller`.

`skip` is an optional `int` which can be used to skip any number of states. `skip` defaults to 0.

`wait` is an optional `Duration` which can be used to wait for async operations within the `controller` under test such as `debounceTime`.

`expect` is an optional `Function` that returns a `Matcher` which the `controller` under test is expected to emit after `act` is executed.

`verify` is an optional callback which is invoked after `expect` and can be used for additional verification/assertions. `verify` is called with the `controller` returned by `build`.

`errors` is an optional `Function` that returns a `Matcher` which the `controller` under test is expected to throw after `act` is executed.

```dart
group('CounterController', () {
  testController(
    'emits [] when nothing is added',
    build: () => CounterController(),
    expect: () => [],
  );

  testController(
    'emits [1] when CounterEvent.increment is added',
    build: () => CounterController(),
    act: (controller) => controller.add(CounterEvent.increment),
    expect: () => [1],
  );
});
```

`testController` can optionally be used with a seeded state.

```dart
testController(
  'CounterController emits [10] when seeded with 9',
  build: () => CounterController(),
  seed: () => 9,
  act: (controller) => controller.increment(),
  expect: () => [10],
);
```

`testController` can also be used to `skip` any number of emitted states before asserting against the expected states. The default value is 0.

```dart
testController(
  'CounterController emits [2] when CounterEvent.increment is added twice',
  build: () => CounterController(),
  act: (controller) => controller..add(CounterEvent.increment)..add(CounterEvent.increment),
  skip: 1,
  expect: () => [2],
);
```

`testController` can also be used to wait for async operations like `debounceTime` by providing a `Duration` to `wait`.

```dart
testController(
  'CounterController emits [1] when CounterEvent.increment is added',
  build: () => CounterController(),
  act: (controller) => controller.add(CounterEvent.increment),
  wait: const Duration(milliseconds: 300),
  expect: () => [1],
);
```

`testController` can also be used to `verify` internal controller functionality.

```dart
testController(
  'CounterController emits [1] when CounterEvent.increment is added',
  build: () => CounterController(),
  act: (controller) => controller.add(CounterEvent.increment),
  expect: () => [1],
  verify: (_) {
    verify(() => repository.someMethod(any())).called(1);
  }
);
```

`testController` can also be used to expect that exceptions have been thrown.

```dart
testController(
  'CounterController throws Exception when null is added',
  build: () => CounterController(),
  act: (controller) => controller.add(null),
  errors: () => [isA<Exception>()]
);
```

**Note:** when using `testController` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
testController(
  'emits [StateB] when MyEvent is added',
  build: () => MyController(),
  act: (controller) => controller.add(MyEvent()),
  expect: () => [isA<StateB>()],
);
```
