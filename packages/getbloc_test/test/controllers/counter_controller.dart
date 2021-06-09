import 'dart:async';

import 'package:getbloc/getbloc.dart';

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
