import 'package:getbloc/getbloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'controllers/counter/counter_controller.dart';

void main() {
  final controller = CounterController();
  const event = CounterEvent.increment;
  const stateChange = StateChange(currentState: 0, nextState: 1);
  const transform = TransformController(
    currentState: 0,
    event: CounterEvent.increment,
    nextState: 1,
  );
  group('ObserverController', () {
    group('onCreate', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        ObserverController().onCreate(controller);
      });
    });

    group('onEvent', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        ObserverController().onEvent(controller, event);
      });
    });

    group('onChange', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        ObserverController().onChange(controller, stateChange);
      });
    });

    group('onTransform', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        ObserverController().onTransform(controller, transform);
      });
    });

    group('onError', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        ObserverController().onError(controller, event, StackTrace.current);
      });
    });

    group('onClose', () {
      test('does nothing by default', () {
        // ignore: invalid_use_of_protected_member
        ObserverController().onClose(controller);
      });
    });
  });
}
