import 'dart:async';

import 'package:getbloc/getbloc.dart';

import 'counter_controller.dart';

class OnErrorController extends Controller<CounterEvent, int> {
  OnErrorController({required this.error, required this.onErrorCallback})
      : super(0);

  final Function onErrorCallback;
  final Error error;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    throw error;
  }
}
