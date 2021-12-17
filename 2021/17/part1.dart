import '../utils.dart';

class TargetArea {
  /// The left-most x-coordinate
  final int x1;

  /// The right-most x-coordinate
  final int x2;

  /// The lower y-coordinate
  final int y1;

  /// The upper y-coordinate
  final int y2;

  TargetArea(this.x1, this.x2, this.y1, this.y2);

  bool isInArea(Coordinate coordinate) {
    return x1 <= coordinate.x &&
        coordinate.x <= x2 &&
        y1 <= coordinate.y &&
        coordinate.y <= y2;
  }

  @override
  String toString() {
    return 'TargetArea($x1..$x2, $y1..$y2)';
  }
}

Future<TargetArea> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();
  assert(lines.length == 1);

  /// Assuming the input is like
  /// target area: x=137..171, y=-98..-73
  final regex = RegExp(r'target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)');
  final match = regex.firstMatch(lines[0])!;
  assert(match.groupCount == 5);
  return TargetArea(int.parse(match.group(1)!), int.parse(match.group(2)!),
      int.parse(match.group(3)!), int.parse(match.group(4)!));
}

void main() async {
  final targetArea = await parseInput('17/demo');
  print(targetArea);
}
