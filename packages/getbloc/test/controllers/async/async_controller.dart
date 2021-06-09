import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:meta/meta.dart';

part 'async_event.dart';
part 'async_state.dart';

class AsyncController extends Controller<AsyncEvent, AsyncState> {
  AsyncController() : super(AsyncState.initial());

  @override
  Stream<AsyncState> mapEventToState(AsyncEvent event) async* {
    yield state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    yield state.copyWith(isLoading: false, isSuccess: true);
  }
}
