import './shared.dart';
import '../utils.dart';

final MAX = 4000000;
bool inBounds(Coordinate coord) {
  return coord.x >= 0 && coord.y >= 0 && coord.x <= MAX && coord.y <= MAX;
}

/**
 * It's not efficient but it gets the job done--we build a set of coordinates 
 * around the outside of a sensor's range and check every single one against the
 * manhattan distances for all the other sensors. Since it's guaranteed that 
 * there can only ever be 1 in a range 0 <= (x|y) <= 4000000, we know that it
 * must touch a given sensor's zone.
 * 
 * It would be slightly more efficient to find midpoints between sensors, 
 * evaluate if they fall inside of sensed regions, and expand around the edges
 * until a point is found. 
 * 
 * Alas, neither solution is all that fast nor are they more important than my
 * sleep.
 */
void main() async {
  final input = await parseInput('15/input');
  final distances = manhattanDistances(input);
  final sensors = input.map((pair) => pair.first).toList();

  final Set<Coordinate> maybes = new Set();
  for (int idx in range(distances.length)) {
    final distance = distances[idx] + 1;
    final sensor = sensors[idx];
    final Set<Coordinate> outsides = new Set();
    for (int i in range(distance)) {
      final y = distance - i;
      final topRight = Coordinate(sensor.x + i, sensor.y - y);
      if (inBounds(topRight)) outsides.add(topRight);
      final bottomRight = Coordinate(sensor.x + i, sensor.y + y);
      if (inBounds(bottomRight)) outsides.add(bottomRight);
      final topLeft = Coordinate(sensor.x - i, sensor.y - y);
      if (inBounds(topLeft)) outsides.add(topLeft);
      final bottomLeft = Coordinate(sensor.x - i, sensor.y + y);
      if (inBounds(bottomLeft)) outsides.add(bottomLeft);
    }
    print("Eval outsides of ${idx + 1}/${distances.length}");
    outsides.forEach((element) {
      bool canDo = true;
      for (int jdx in range(distances.length)) {
        if (idx == jdx) continue;
        final distance = distances[jdx];
        final sensor = sensors[jdx];
        if (manhattenDistance(element, sensor) <= distance) {
          canDo = false;
          break;
        }
      }
      if (canDo) {
        maybes.add(element);
      }
    });
  }

  assert(maybes.length == 1);
  final end = maybes.first;
  final result = end.x * MAX + end.y;
  print(result);
}
