import 'package:getbloc/getbloc.dart';
import 'package:rxdart/rxdart.dart';

import 'counter_controller.dart';

class MergeController extends Controller<CounterEvent, int> {
  MergeController({this.onTransformCallback}) : super(0);

  final void Function(TransformController<CounterEvent, int>)?
      onTransformCallback;

  @override
  void onTransform(TransformController<CounterEvent, int> transition) {
    super.onTransform(transition);
    onTransformCallback?.call(transition);
  }

  @override
  Stream<TransformController<CounterEvent, int>> transformEvents(
    Stream<CounterEvent> events,
    TransitionFunction<CounterEvent, int> transitionFn,
  ) {
    final nonDebounceStream =
        events.where((event) => event != CounterEvent.increment);

    final debounceStream = events
        .where((event) => event == CounterEvent.increment)
        .throttleTime(const Duration(milliseconds: 100));

    return super.transformEvents(
      MergeStream([nonDebounceStream, debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<int> mapEventToState(
    CounterEvent event,
  ) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
