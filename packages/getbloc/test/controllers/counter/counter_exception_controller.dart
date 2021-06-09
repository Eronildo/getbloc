import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class CounterExceptionController extends Controller<CounterEvent, int> {
  CounterExceptionController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        throw Exception('fatal exception');
    }
  }
}
