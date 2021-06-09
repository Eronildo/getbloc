import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class Repository {
  void sideEffect() {}
}

class SideEffectCounterController extends Controller<CounterEvent, int> {
  SideEffectCounterController(this.repository) : super(0);

  final Repository repository;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        repository.sideEffect();
        yield state + 1;
        break;
      case CounterEvent.decrement:
        repository.sideEffect();
        yield state - 1;
        break;
    }
  }
}
