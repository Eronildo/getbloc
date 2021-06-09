import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:rxdart/rxdart.dart';

import 'controllers.dart';

class DebounceCounterController extends Controller<CounterEvent, int> {
  DebounceCounterController() : super(0);

  @override
  Stream<TransformController<CounterEvent, int>> transformEvents(
    Stream<CounterEvent> events,
    TransitionFunction<CounterEvent, int> transitionFn,
  ) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(transitionFn);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
