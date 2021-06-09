import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class OnEventErrorController extends Controller<CounterEvent, int> {
  OnEventErrorController({required this.exception}) : super(0);

  final Exception exception;

  @override
  // ignore: must_call_super
  void onEvent(CounterEvent event) {
    throw exception;
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {}
}
