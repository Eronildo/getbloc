import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getbloc/getbloc.dart';

/// Custom [ObserverController] which observes all controllers instances.
class SimpleObserverController extends ObserverController {
  @override
  void onEvent(Controller controller, Object? event) {
    super.onEvent(controller, event);
    print(event);
  }

  @override
  void onTransform(Controller controller, TransformController transition) {
    super.onTransform(controller, transition);
    print(transition);
  }

  @override
  void onError(BaseController controller, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(controller, error, stackTrace);
  }

  @override
  void onChange(BaseController controller, StateChange change) {
    print(change);
    super.onChange(controller, change);
  }
}

void main() {
  Controller.observer = SimpleObserverController();
  runApp(App());
}

/// A [StatelessWidget] which uses:
/// * [get](https://pub.dev/packages/get)
/// * [getbloc](https://pub.dev/packages/getbloc)
/// to manage the state of a counter.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      getPages: [
        GetPage<CounterPage>(
          name: '/',
          page: () => CounterPage(),
          binding: CounterBinding(),
        )
      ],
    );
  }
}

/// Binding class to connect the page with the controller
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ButtonsOrientationController());
    // ignore: cascade_invocations
    Get.lazyPut(() => CounterController());
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterController].
class CounterPage extends GetView<CounterController> {
  final _buttonsOrientationController =
      Get.find<ButtonsOrientationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: ListenerWidget(
        _buttonsOrientationController, // Listen the state change of the buttons orientation
        (state) => print('[ListenerWidget]: $state'),
        child: ObserverWidget(
          controller,
          (counter) => Center(
            child:
                Text('$counter', style: Theme.of(context).textTheme.headline1),
          ),
        ),
      ),
      floatingActionButton: _floatingButtons,
    );
  }

  Widget get _floatingButtons =>
      _buttonsOrientationController.obx((orientation) {
        if (orientation == ButtonsOrientation.vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buttons,
          );
        }

        // Horizontal
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buttons,
        );
      });

  List<Widget> get _buttons => [
        _getButton(
          _buttonsOrientationController.state == ButtonsOrientation.vertical
              ? Icons.swap_horiz
              : Icons.swap_vert,
          _buttonsOrientationController.toggleOrientation,
        ),
        _getButton(
          Icons.add,
          () => controller.add(CounterEvent.increment),
        ),
        _getButton(
          Icons.remove,
          () => controller.add(CounterEvent.decrement),
        ),
        _getButton(
          Icons.brightness_6,
          () => Get.changeThemeMode(
            Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
          ),
        ),
        _getButton(
          Icons.error,
          () => controller.add(CounterEvent.error),
          isError: true,
        ),
      ];

  Widget _getButton(IconData iconData, VoidCallback onPressed,
          {bool isError = false}) =>
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: FloatingActionButton(
          backgroundColor: isError
              ? Colors.red
              : Get.theme.floatingActionButtonTheme.backgroundColor,
          child: Icon(iconData),
          onPressed: onPressed,
        ),
      );
}

/// Event being processed by [CounterController].
enum CounterEvent {
  /// Notifies controller to increment state.
  increment,

  /// Notifies controller to decrement state.
  decrement,

  /// Notifies the controller of an error
  error,
}

/// {@template counter_controller}
/// A simple [Controller] which manages an `int` as its state.
/// {@endtemplate}
class CounterController extends Controller<CounterEvent, int> {
  /// {@macro counter_controller}
  CounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.error:
        addError(Exception('unsupported event'));
    }
  }
}

/// Buttons Orientation State
enum ButtonsOrientation {
  /// Horizontal Orientation
  horizontal,

  /// Vertical Orientation
  vertical,
}

/// {@template buttons_orientation_controller}
/// A simple [StateController] which manages the [ButtonsOrientation] as its state.
/// {@endtemplate}
class ButtonsOrientationController extends StateController<ButtonsOrientation> {
  /// {@macro buttons_orientation_controller}
  ButtonsOrientationController() : super(ButtonsOrientation.vertical);

  /// Change the state to another orientation.
  void toggleOrientation() {
    emit(state == ButtonsOrientation.vertical
        ? ButtonsOrientation.horizontal
        : ButtonsOrientation.vertical);
  }
}
