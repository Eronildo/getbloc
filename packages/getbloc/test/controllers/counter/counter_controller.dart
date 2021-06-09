import 'dart:async';

import 'package:getbloc/getbloc.dart';

typedef OnEventCallback = Function(CounterEvent);
typedef OnTransformCallback = Function(TransformController<CounterEvent, int>);
typedef OnErrorCallback = Function(Object error, StackTrace? stackTrace);

enum CounterEvent { increment, decrement }

class CounterController extends Controller<CounterEvent, int> {
  CounterController({
    this.onEventCallback,
    this.onTransformCallback,
    this.onErrorCallback,
  }) : super(0);

  final OnEventCallback? onEventCallback;
  final OnTransformCallback? onTransformCallback;
  final OnErrorCallback? onErrorCallback;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onEvent(CounterEvent event) {
    super.onEvent(event);
    onEventCallback?.call(event);
  }

  @override
  void onTransform(TransformController<CounterEvent, int> transition) {
    super.onTransform(transition);
    onTransformCallback?.call(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback?.call(error, stackTrace);
    super.onError(error, stackTrace);
  }
}
