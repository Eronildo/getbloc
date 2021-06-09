import 'dart:async';

import 'package:getbloc/getbloc.dart';

abstract class ComplexTestEvent {}

class ComplexTestEventA extends ComplexTestEvent {}

class ComplexTestEventB extends ComplexTestEvent {}

abstract class ComplexTestState {}

class ComplexTestStateA extends ComplexTestState {}

class ComplexTestStateB extends ComplexTestState {}

class ComplexTestController
    extends Controller<ComplexTestEvent, ComplexTestState> {
  ComplexTestController() : super(ComplexTestStateA());

  @override
  Stream<ComplexTestState> mapEventToState(ComplexTestEvent event) async* {
    if (event is ComplexTestEventA) {
      yield ComplexTestStateA();
    } else if (event is ComplexTestEventB) {
      yield ComplexTestStateB();
    }
  }
}
