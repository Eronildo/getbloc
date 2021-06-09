import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class OnExceptionController extends Controller<CounterEvent, int> {
  OnExceptionController({
    required this.exception,
    required this.onErrorCallback,
  }) : super(0);

  final Function onErrorCallback;
  final Exception exception;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    throw exception;
  }
}
