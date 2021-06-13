import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:getbloc/src/controller.dart';

/// {@template observer_widget}
/// [ObserverWidget] handles building a widget in response to new `states`.
///
/// Please refer to `ListenerWidget` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// ```dart
/// ObserverWidget(
///   controller,
///   (state) {
///     // return widget here based on Controller's state
///     return Container();
///   },
/// )
/// ```
/// {@endtemplate}
class ObserverWidget<State> extends StatelessWidget {
  /// {@macro observer_widget}
  const ObserverWidget(this.controller, this.builder, {Key? key})
      : super(key: key);

  /// The [controller] that the [ObserverWidget] will interact with.
  final BaseController<State> controller;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the current `state` and must return a widget.
  final Widget Function(State) builder;

  @override
  Widget build(BuildContext context) => ObxValue<Rx<State>>(
        (state) => builder(state.value),
        controller.rxState,
        key: key,
      );
}
