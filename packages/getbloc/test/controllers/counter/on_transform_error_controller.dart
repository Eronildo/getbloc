import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class OnTransformErrorController extends Controller<CounterEvent, int> {
  OnTransformErrorController({
    required this.error,
    required this.onErrorCallback,
  }) : super(0);

  final Function onErrorCallback;
  final Error error;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  void onTransform(TransformController<CounterEvent, int> transition) {
    super.onTransform(transition);
    throw error;
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
        break;
    }
  }
}
