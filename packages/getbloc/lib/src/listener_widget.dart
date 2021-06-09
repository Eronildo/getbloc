import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getbloc/src/controller.dart';

/// Signature for the `listener` function which takes the `state`
/// and is responsible for executing in response to `state` changes.
typedef ListenerCallback = void Function(dynamic state);

/// {@template listener_widget}
/// Takes a [Controller] and a [ListenerCallback] and invokes
/// the [listener] in response to `state` changes in the [Controller].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change.
///
/// ```dart
/// ListenerWidget(
///   controller,
///   (state) {
///     // do stuff here based on Controller's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class ListenerWidget extends StatefulWidget {
  /// {@macro listener_widget}
  const ListenerWidget(this.controller, this.listener, {this.child});

  /// The [controller] whose `state` will be listened to.
  /// Whenever the [controller]'s `state` changes, [listener] will be invoked.
  final BaseController controller;

  /// The [ListenerCallback] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final ListenerCallback listener;

  /// The widget which will be rendered as a descendant of the
  /// [ListenerWidget].
  final Widget? child;

  @override
  _ListenerWidgetState createState() => _ListenerWidgetState();
}

class _ListenerWidgetState extends State<ListenerWidget> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    _subscribe();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ListenerWidget oldWidget) {
    final oldController = oldWidget.controller;
    final currentController = widget.controller;
    if (oldController != currentController) {
      _unsubscribe();
      _subscribe();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  bool get _hasChild => widget.child != null;

  @override
  Widget build(BuildContext context) {
    return _hasChild ? widget.child! : const SizedBox.shrink();
  }

  void _subscribe() {
    _subscription = widget.controller.rxState.listen(
      widget.listener,
      cancelOnError: false,
    );
  }

  void _unsubscribe() {
    _subscription.cancel();
  }
}
