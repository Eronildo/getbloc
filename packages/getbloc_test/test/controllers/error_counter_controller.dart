import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'controllers.dart';

class ErrorCounterControllerError extends Error {}

class ErrorCounterController extends Controller<CounterEvent, int> {
  ErrorCounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        throw ErrorCounterControllerError();
    }
  }
}
