import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'controllers.dart';

class MultiCounterController extends Controller<CounterEvent, int> {
  MultiCounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        yield state + 1;
        break;
    }
  }
}
