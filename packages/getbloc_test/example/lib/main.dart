import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getbloc/getbloc.dart';
import 'package:getbloc_test/getbloc_test.dart';

/// A Mocked Counter Controller
class MockCounterController extends MockController<CounterEvent, int>
    implements CounterController {}

/// A Stub of Counter Event
class FakeCounterEvent extends Fake implements CounterEvent {}

void main() {
  late CounterController counterController;

  setUpAll(() {
    registerFallbackValue<CounterEvent>(FakeCounterEvent());
  });

  setUp(() {
    counterController = Get.put(MockCounterController());
  });

  tearDown(Get.reset);

  testWidgets('renders a counter 5', (WidgetTester tester) async {
    counterController.whenState(5);
    await tester.pumpWidget(GetMaterialApp(home: CounterPage()));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('renders a counter 10 and call increment event',
      (WidgetTester tester) async {
    counterController.whenState(10);
    await tester.pumpWidget(GetMaterialApp(home: CounterPage()));
    await tester.tap(find.byTooltip('increment'));
    expect(find.text('10'), findsOneWidget);
    verify(() => counterController.add(Increment())).called(1);
  });

  testWidgets('renders a counter -1 and call decrement event',
      (WidgetTester tester) async {
    counterController.whenState(-1);
    await tester.pumpWidget(GetMaterialApp(home: CounterPage()));
    await tester.tap(find.byTooltip('decrement'));
    expect(find.text('-1'), findsOneWidget);
    verify(() => counterController.add(Decrement())).called(1);
  });
}

/// A [StatelessWidget] which uses:
/// * [get](https://pub.dev/packages/get)
/// * [getbloc](https://pub.dev/packages/getbloc)
/// to manage the state of a counter.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage<CounterPage>(
          name: '/',
          page: () => CounterPage(),
          binding: CounterBinding(),
        ),
      ],
    );
  }
}

/// Binding class to connect the page with the controller
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CounterController());
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterController].
class CounterPage extends GetView<CounterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: controller.obx(
        (counter) => Text(
          '$counter',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buttons,
      ),
    );
  }

  List<Widget> get _buttons => [
        _getButton(
          Icons.add,
          () => controller.add(Increment()),
          'increment',
        ),
        _getButton(
          Icons.remove,
          () => controller.add(Decrement()),
          'decrement',
        ),
      ];

  Widget _getButton(
          IconData iconData, VoidCallback onPressed, String tooltipText) =>
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: FloatingActionButton(
          tooltip: tooltipText,
          backgroundColor: Get.theme.floatingActionButtonTheme.backgroundColor,
          child: Icon(iconData),
          onPressed: onPressed,
        ),
      );
}

/// {@template counter_event}
/// Event being processed by [CounterController].
/// {@endtemplate}
abstract class CounterEvent extends Equatable {
  /// {@macro counter_event}
  const CounterEvent();

  @override
  List<Object> get props => [];
}

/// Notifies controller to increment state.
class Increment extends CounterEvent {}

/// Notifies controller to decrement state.
class Decrement extends CounterEvent {}

/// {@template counter_controller}
/// A simple [Controller] which manages an `int` as its state.
/// {@endtemplate}
class CounterController extends Controller<CounterEvent, int> {
  /// {@macro counter_controller}
  CounterController() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    }
    if (event is Decrement) {
      yield state - 1;
    }
  }
}
