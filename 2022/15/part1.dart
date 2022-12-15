import './shared.dart';
import '../utils.dart';

bool contains(Input input, Coordinate coordinate) {
  return input
      .any((pair) => pair.first == coordinate || pair.second == coordinate);
}

void main() async {
  final input = await parseInput('15/input');
  final y = 2000000;

  // final input = await parseInput('15/demo');
  // final y = 10;

  final distances = manhattanDistances(input);
  final buffer = (maxItem(distances) / 2).ceil();
  final dimens = Dimens.fromInput(input, buffer);

  int cannotContain = 0;
  for (int x in range(dimens.topLeft.x, dimens.bottomRight.x + 1)) {
    final coordinate = Coordinate(x, y);
    // Within a Manhattan distance?
    for (int idx in range(input.length)) {
      final sensor = input[idx].first;
      if (manhattenDistance(coordinate, sensor) <= distances[idx] &&
          !contains(input, coordinate)) {
        cannotContain++;
        break;
      }
    }
  }
  print(cannotContain);
}
