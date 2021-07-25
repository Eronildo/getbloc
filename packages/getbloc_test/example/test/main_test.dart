import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getbloc/getbloc.dart';
import 'package:getbloc_test/getbloc_test.dart';

///
class MockCounterController extends MockController<CounterEvent, int>
    implements CounterController {}

///
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
