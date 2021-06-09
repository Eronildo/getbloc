import 'dart:async';

import 'package:getbloc/getbloc.dart';

class SimpleController extends Controller<dynamic, String> {
  SimpleController() : super('');

  @override
  Stream<String> mapEventToState(dynamic event) async* {
    yield 'data';
  }
}
