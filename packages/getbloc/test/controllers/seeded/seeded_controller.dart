import 'package:getbloc/getbloc.dart';

class SeededController extends Controller<String, int> {
  SeededController({required this.seed, required this.states}) : super(seed);

  final List<int> states;
  final int seed;

  @override
  Stream<int> mapEventToState(String event) async* {
    for (final state in states) {
      yield state;
    }
  }
}
