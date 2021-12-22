import '../utils.dart';
import './parse.dart';

void main() async {
  final input = await parseInput('22/input');

  final naiveMap = Map<String, bool>();
  input.initializationProcedure.forEach((step) {
    for (int x in range(step.coords[0], step.coords[1] + 1)) {
      for (int y in range(step.coords[2], step.coords[3] + 1)) {
        for (int z in range(step.coords[4], step.coords[5] + 1)) {
          final key = '($x,$y,$z)';
          if (step.turnOn) {
            naiveMap[key] = true;
          } else {
            naiveMap.remove(key);
          }
        }
      }
    }
  });

  /// Afterward, considering only cubes in the region x=-50..50,y=-50..50,z=-50..50, how many cubes are on?
  print(naiveMap.length);
}
