import 'dart:async';

import 'package:meta/meta.dart';
import 'package:getbloc/getbloc.dart';
import 'package:rxdart/rxdart.dart';

part 'complex_event.dart';
part 'complex_state.dart';

class ComplexController extends Controller<ComplexEvent, ComplexState> {
  ComplexController() : super(ComplexStateA());

  @override
  Stream<TransformController<ComplexEvent, ComplexState>> transformEvents(
    Stream<ComplexEvent> events,
    TransitionFunction<ComplexEvent, ComplexState> transitionFn,
  ) {
    return events.switchMap(transitionFn);
  }

  @override
  Stream<ComplexState> mapEventToState(ComplexEvent event) async* {
    if (event is ComplexEventA) {
      yield ComplexStateA();
    } else if (event is ComplexEventB) {
      yield ComplexStateB();
    } else if (event is ComplexEventC) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield ComplexStateC();
    } else if (event is ComplexEventD) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield ComplexStateD();
    }
  }

  @override
  Stream<TransformController<ComplexEvent, ComplexState>> transformTransitions(
    Stream<TransformController<ComplexEvent, ComplexState>> transitions,
  ) {
    return transitions.debounceTime(const Duration(milliseconds: 50));
  }
}
