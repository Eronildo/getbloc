import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'controllers.dart';

class ExceptionCounterControllerException implements Exception {}

class ExceptionCounterController extends Controller<CounterEvent, int> {
  ExceptionCounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        throw ExceptionCounterControllerException();
    }
  }
}
