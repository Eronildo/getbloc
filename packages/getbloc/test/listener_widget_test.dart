import 'package:flutter/material.dart';
import 'package:getbloc/getbloc.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleCounterStateController extends StateController<int> {
  SimpleCounterStateController() : super(0);

  void increment() => emit(state + 1);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.onListenerCalled}) : super(key: key);

  final ListenerCallback? onListenerCalled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SimpleCounterStateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleCounterStateController();
  }

  @override
  void dispose() {
    _controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListenerWidget(
          _controller,
          (state) {
            widget.onListenerCalled?.call(state);
          },
          child: Column(
            children: [
              ElevatedButton(
                key: const Key('controller_listener_reset_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _controller = SimpleCounterStateController());
                },
              ),
              ElevatedButton(
                key: const Key('controller_listener_noop_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _controller = _controller);
                },
              ),
              ElevatedButton(
                key: const Key('controller_listener_increment_button'),
                child: const SizedBox(),
                onPressed: () => _controller.increment(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('ListenerWidget', () {
    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('controller_listener_container');
      await tester.pumpWidget(
        ListenerWidget(
          SimpleCounterStateController(),
          (__) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('calls listener on single state change', (tester) async {
      final controller = SimpleCounterStateController();
      final states = <int>[];
      const expectedStates = [1];
      await tester.pumpWidget(
        ListenerWidget(
          controller,
          (state) => states.add(state as int),
          child: const SizedBox(),
        ),
      );
      controller.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets('calls listener on multiple state change', (tester) async {
      final controller = SimpleCounterStateController();
      final states = <int>[];
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        ListenerWidget(
          controller,
          (state) => states.add(state as int),
          child: const SizedBox(),
        ),
      );
      controller.increment();
      await tester.pump();
      controller.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets(
        'updates when the controller is changed at runtime to a different controller '
        'and unsubscribes from old controller', (tester) async {
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('controller_listener_increment_button'),
      );
      final resetControllerFinder = find.byKey(
        const Key('controller_listener_reset_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (state) {
          listenerCallCount++;
          latestState = state as int;
        },
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(resetControllerFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 1);
    });

    testWidgets(
        'does not update when the controller is changed at runtime to same controller '
        'and stays subscribed to current controller', (tester) async {
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('controller_listener_increment_button'),
      );
      final noopControllerFinder = find.byKey(
        const Key('controller_listener_noop_button'),
      );
      await tester.pumpWidget(MyApp(
        onListenerCalled: (state) {
          listenerCallCount++;
          latestState = state as int;
        },
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(noopControllerFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 3);
    });
  });
}
