import '../utils.dart';

class Step {
  final bool turnOn;

  /// length 6
  final List<int> coords;

  Step(this.turnOn, this.coords);

  bool get isInitialization {
    final acceptableRange = range(-50, 51);
    return this.coords.every((element) => acceptableRange.contains(element));
  }

  @override
  String toString() {
    return 'Step(x=${coords[0]}..${coords[1]},y=${coords[2]}..${coords[3]},z=${coords[4]}..${coords[5]})';
  }
}

class Input {
  final List<Step> initializationProcedure;
  final List<Step> outsideProcedure;

  Input(this.initializationProcedure, this.outsideProcedure);
}

Future<Input> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();

  /// on x=-20..26,y=-36..17,z=-47..7
  final stepRegex = RegExp(
      r'^(\w+) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)$');

  final List<Step> initializationProcedures = [];
  final List<Step> outsideProcedure = [];
  bool isInInitialization = true;

  lines.forEach((line) {
    final matches = stepRegex.firstMatch(line)!;
    assert(matches.groupCount == 7);
    final turnOn = matches.group(1) == 'on';
    final coords = matches
        .groups([2, 3, 4, 5, 6, 7])
        .map((element) => int.parse(element!))
        .toList();
    final step = Step(turnOn, coords);
    isInInitialization &= step.isInitialization;
    if (isInInitialization) {
      initializationProcedures.add(step);
    } else {
      outsideProcedure.add(step);
    }
  });

  return Input(initializationProcedures, outsideProcedure);
}
