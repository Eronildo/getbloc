import 'package:getbloc/getbloc.dart';

import 'controllers.dart';

class InstantEmitController extends Controller<CounterEvent, int> {
  InstantEmitController() : super(0) {
    add(CounterEvent.increment);
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
