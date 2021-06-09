import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:getbloc_test/getbloc_test.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerFallbackValue<CounterEvent>(CounterEvent.increment);
  });

  mainStateController();
  mainController();
}

void mainStateController() {
  group('CounterStateController', () {
    testController<CounterStateController, int>(
      'emits [] when nothing is called',
      build: () => CounterStateController(),
      expect: () => const <int>[],
    );

    testController<CounterStateController, int>(
      'emits [1] when increment is called',
      build: () => CounterStateController(),
      act: (controller) => controller.increment(),
      expect: () => const <int>[1],
    );
  });
}

void mainController() {
  group('CounterController', () {
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
  });
}

class CounterStateController extends StateController<int> {
  CounterStateController() : super(0);

  void increment() => emit(state + 1);
}

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
}
