import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getbloc/src/controller.dart';

typedef ListenerCallback = void Function(dynamic state);

/// The [ListenerWidget] is a Listener Widget of the Controller's State.
class ListenerWidget extends StatefulWidget {
  const ListenerWidget(this.controller, this.listener, {this.child});
  final BaseController controller;
  final ListenerCallback listener;
  final Widget? child;

  @override
  _ListenerWidgetState createState() => _ListenerWidgetState();
}

class _ListenerWidgetState extends State<ListenerWidget> {
  late StreamSubscription subs;

  @override
  void initState() {
    subs = widget.controller.rxState.listen(
      widget.listener,
      cancelOnError: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    subs.cancel();
    super.dispose();
  }

  bool get _hasChild => widget.child != null;

  @override
  Widget build(BuildContext context) {
    return _hasChild ? widget.child! : SizedBox.shrink();
  }
}
