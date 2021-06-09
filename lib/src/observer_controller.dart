import 'package:meta/meta.dart';

import 'controller.dart';
import 'transform_controller.dart';

/// An interface for observing the behavior of [Controller] instances.
class ObserverController {
  /// Called whenever a [Controller] is instantiated.
  /// In many cases, a StateController may be lazily instantiated and
  /// [onCreate] can be used to observe exactly when the StateController
  /// instance is created.
  @protected
  @mustCallSuper
  void onCreate(BaseController controller) {}

  /// Called whenever an [event] is `added` to any [controller] with the given [controller]
  /// and [event].
  @protected
  @mustCallSuper
  void onEvent(Controller controller, Object? event) {}

  /// Called whenever a [StateChange] occurs in any [controller]
  /// A [change] occurs when a new state is emitted.
  /// [onChange] is called before a controller's state has been updated.
  @protected
  @mustCallSuper
  void onChange(BaseController controller, StateChange change) {}

  /// Called whenever a transition occurs in any [controller] with the given [controller]
  /// and [transition].
  /// A [transition] occurs when a new `event` is `added` and `mapEventToState`
  /// executed.
  /// [onTransform] is called before a [controller]'s state has been updated.
  @protected
  @mustCallSuper
  void onTransform(Controller controller, TransformController transition) {}

  /// Called whenever an [error] is thrown in any [Controller] or [StateController].
  /// The [stackTrace] argument may be [StackTrace.empty] if an error
  /// was received without a stack trace.
  @protected
  @mustCallSuper
  void onError(
      BaseController controller, Object error, StackTrace stackTrace) {}

  /// Called whenever a [Controller] is closed.
  /// [onClose] is called just before the [Controller] is closed
  /// and indicates that the particular instance will no longer
  /// emit new states.
  @protected
  @mustCallSuper
  void onClose(BaseController controller) {}
}
