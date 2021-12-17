import '../utils.dart';
import './part1.dart';

void main() async {
  final targetArea = await parseInput('17/input');
  // int uniqueVelocityValues = 0;
  int uniqueVelocityCount = 0;
  final maxXVelocity = targetArea.x2 + 1;
  final maxYVelocity = targetArea.y1.abs() + 1;

  /// Generate and test random trajectories within boundary
  for (final velocityX in range(maxXVelocity)) {
    for (final velocityY in range(-maxYVelocity, maxYVelocity)) {
      final simResult = runSimulation(targetArea, velocityX, velocityY);
      if (simResult.first) {
        uniqueVelocityCount++;
      }
    }
  }

  /// How many distinct initial velocity values cause the probe to be within the target area after any step?
  print(uniqueVelocityCount);
}
