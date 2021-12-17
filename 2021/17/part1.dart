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

  bool isInArea(int x, int y) {
    return x1 <= x && x <= x2 && y1 <= y && y <= y2;
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

Pair<bool, int> runSimulation(
    TargetArea targetArea, final int velocityX, final int velocityY) {
  int curVelocityX = velocityX;
  int curVelocityY = velocityY;
  int positionX = 0;
  int positionY = 0;
  int highestY = 0;
  while (positionY >= targetArea.y1) {
    /// Step 1
    positionX += curVelocityX;

    /// Step 2
    positionY += curVelocityY;
    if (curVelocityY == 0) {
      highestY = positionY;
    }

    if (targetArea.isInArea(positionX, positionY)) {
      return Pair(true, highestY);
    }

    /// Step 3
    final vXInc = curVelocityX > 0
        ? -1
        : curVelocityX < 0
            ? 1
            : 0;

    curVelocityX += vXInc;

    /// Step 4
    curVelocityY--;
  }

  return Pair(false, highestY);
}

void main() async {
  final targetArea = await parseInput('17/input');
  int highestY = 0;
  final maxXVelocity = targetArea.x2 + 1;
  final maxYVelocity = targetArea.y1.abs() + 1;
  List.generate(maxXVelocity, (velocityX) {
    List.generate(maxYVelocity, (velocityY) {
      final simResult = runSimulation(targetArea, velocityX, velocityY);
      if (simResult.first) {
        // print(Coordinate(velocityX, velocityY));
        if (simResult.second > highestY) {
          highestY = simResult.second;
        }
      }
    });
  });

  /// What is the highest y position it reaches on this trajectory?
  print(highestY);
}
