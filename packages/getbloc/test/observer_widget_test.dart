import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getbloc/getbloc.dart';

class MyThemeApp extends StatefulWidget {
  MyThemeApp({
    Key? key,
    required StateController<ThemeData> themeController,
    required Function onBuild,
  })  : _themeController = themeController,
        _onBuild = onBuild,
        super(key: key);

  final StateController<ThemeData> _themeController;
  final Function _onBuild;

  @override
  State<MyThemeApp> createState() => MyThemeAppState(
        themeController: _themeController,
        onBuild: _onBuild,
      );
}

class MyThemeAppState extends State<MyThemeApp> {
  MyThemeAppState({
    required StateController<ThemeData> themeController,
    required Function onBuild,
  })  : _themeController = themeController,
        _onBuild = onBuild;

  StateController<ThemeData> _themeController;
  final Function _onBuild;

  @override
  Widget build(BuildContext context) {
    return ObserverWidget<ThemeData>(
      _themeController,
      (theme) {
        _onBuild();
        return MaterialApp(
          key: const Key('material_app'),
          theme: theme,
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('raised_button_1'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _themeController = DarkThemeController());
                },
              ),
              ElevatedButton(
                key: const Key('raised_button_2'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _themeController = _themeController);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemeController extends StateController<ThemeData> {
  ThemeController() : super(ThemeData.light());

  void setDarkTheme() => emit(ThemeData.dark());
  void setLightTheme() => emit(ThemeData.light());
}

class DarkThemeController extends StateController<ThemeData> {
  DarkThemeController() : super(ThemeData.dark());

  void setDarkTheme() => emit(ThemeData.dark());
  void setLightTheme() => emit(ThemeData.light());
}

class MyCounterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyCounterAppState();
}

class MyCounterAppState extends State<MyCounterApp> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: const Key('myCounterApp'),
        body: Column(
          children: <Widget>[
            ObserverWidget<int>(
              _controller,
              (count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppText'),
                );
              },
            ),
            ElevatedButton(
              key: const Key('myCounterAppIncrementButton'),
              child: const SizedBox(),
              onPressed: _controller.increment,
            )
          ],
        ),
      ),
    );
  }
}

class CounterController extends StateController<int> {
  CounterController() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

void main() {
  group('ObserverWidget', () {
    testWidgets('passes initial state to widget', (tester) async {
      final themeController = ThemeController();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
            themeController: themeController, onBuild: () => numBuilds++),
      );

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget',
        (tester) async {
      final themeController = ThemeController();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
            themeController: themeController, onBuild: () => numBuilds++),
      );

      themeController.setDarkTheme();

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'updates controller and performs new lookup when widget is updated',
        (tester) async {
      final themeController = ThemeController();
      var numBuilds = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => ObserverWidget<ThemeData>(
            themeController,
            (theme) {
              numBuilds++;
              return MaterialApp(
                key: const Key('material_app'),
                theme: theme,
                home: ElevatedButton(
                  child: const SizedBox(),
                  onPressed: () => setState(() {}),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 2);
    });

    testWidgets(
        'updates when the controller is changed at runtime to a different controller and '
        'unsubscribes from old controller', (tester) async {
      final themeController = ThemeController();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
            themeController: themeController, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_1')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeController.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the controller is changed at runtime to same controller '
        'and stays subscribed to current controller', (tester) async {
      final themeController = DarkThemeController();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
            themeController: themeController, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_2')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeController.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state', (tester) async {
      final themeController = ThemeController()..setDarkTheme();
      await tester.pumpAndSettle();

      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
            themeController: themeController, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds when provided controller is changed', (tester) async {
      final firstCounterController = CounterController();
      final secondCounterController = CounterController()..emit(100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ObserverWidget<int>(
            firstCounterController,
            (state) => Text('Count $state'),
          ),
        ),
      );

      expect(find.text('Count 0'), findsOneWidget);

      firstCounterController.increment();
      await tester.pumpAndSettle();
      expect(find.text('Count 1'), findsOneWidget);
      expect(find.text('Count 0'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ObserverWidget<int>(
            secondCounterController,
            (state) => Text('Count $state'),
          ),
        ),
      );

      expect(find.text('Count 100'), findsOneWidget);
      expect(find.text('Count 1'), findsNothing);

      secondCounterController.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count 101'), findsOneWidget);
    });
  });
}
