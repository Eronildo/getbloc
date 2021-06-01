import 'dart:async';

import 'package:get/get.dart';
import 'package:meta/meta.dart';

abstract class Controller<Event, State> extends BaseController<State> {
  Controller(State initialState) : super(initialState) {
    _eventController.stream.listen((value) {
      if (_isAddStreamCompleted) {
        _isAddStreamCompleted = false;
        _stateController.addStream(mapEventToState(value)).whenComplete(
              () => _isAddStreamCompleted = true,
            );
      }
    });
  }

  final _eventController = StreamController<Event>.broadcast();

  bool _isAddStreamCompleted = true;

  @protected
  @visibleForOverriding
  Stream<State> mapEventToState(Event event);

  void add(Event event) {
    if (_eventController.isClosed) return;
    _eventController.add(event);
  }

  @override
  void onClose() {
    _eventController.close();
    super.onClose();
  }
}

abstract class StateController<State> extends StateBase<State> {
  StateController(State initialState) : super(initialState);
}

abstract class BaseController<State> extends StateBase<State> {
  BaseController(State initialState) : super(initialState) {
    _stateController.stream.listen((value) {
      state = value;
    });
  }

  final _stateController = StreamController<State>.broadcast();

  Stream<State> get stream => _stateController.stream;

  @override
  @mustCallSuper
  void onClose() {
    _stateController.close();
    super.onClose();
  }
}

abstract class StateBase<State> extends GetxController {
  StateBase(this._initialState) {
    state = _initialState;
  }

  final State _initialState;

  late final rxState = Rx<State>(_initialState);

  State get state => rxState.value;
  set state(State value) => rxState.value = value;
}
