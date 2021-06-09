import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'controllers.dart';

class AsyncCounterController extends Controller<CounterEvent, int> {
  AsyncCounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        await Future<void>.delayed(const Duration(microseconds: 1));
        yield state + 1;
        break;
    }
  }
}
