import './shared.dart';
import '../utils.dart';

final MAX = 4000000;
bool inBounds(Coordinate coord) {
  return coord.x >= 0 && coord.y >= 0 && coord.x <= MAX && coord.y <= MAX;
}

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
