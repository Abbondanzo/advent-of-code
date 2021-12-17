import './part1.dart';

void main() async {
  final targetArea = await parseInput('17/input');
  // int uniqueVelocityValues = 0;
  int uniqueVelocityCount = 0;
  final maxXVelocity = targetArea.x2 + 1;
  final maxYVelocity = targetArea.y1.abs() + 1;
  List.generate(maxXVelocity, (velocityX) {
    List.generate(2 * maxYVelocity, (toAdd) {
      final velocityY = toAdd - maxYVelocity;
      final simResult = runSimulation(targetArea, velocityX, velocityY);
      if (simResult.first) {
        uniqueVelocityCount++;
      }
    });
  });

  /// How many distinct initial velocity values cause the probe to be within the target area after any step?
  print(uniqueVelocityCount);
}
