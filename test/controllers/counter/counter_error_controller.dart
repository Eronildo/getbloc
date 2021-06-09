import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class CounterErrorController extends Controller<CounterEvent, int> {
  CounterErrorController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        throw Error();
    }
  }
}
