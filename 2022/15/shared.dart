import '../utils.dart';

typedef Input = List<Pair<Coordinate, Coordinate>>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final regexp = new RegExp(r"(-?\d+)");
  return inputLineList.map((line) {
    final matches = regexp.allMatches(line);
    assert(matches.length == 4);
    final numbers = matches.map((match) => int.parse(match.group(1)!)).toList();
    return Pair(
        Coordinate(numbers[0], numbers[1]), Coordinate(numbers[2], numbers[3]));
  }).toList();
}

class Dimens {
  final Coordinate topLeft;
  final Coordinate bottomRight;

  Dimens(this.topLeft, this.bottomRight);

  static Dimens fromInput(Input input, int buffer) {
    assert(input.length >= 1);
    int minX = input[0].first.x;
    int minY = input[0].first.y;
    int maxX = input[0].first.x;
    int maxY = input[0].first.y;
    for (final pair in input) {
      for (final coord in [pair.first, pair.second]) {
        if (minX > coord.x) {
          minX = coord.x;
        }
        if (minY > coord.y) {
          minY = coord.y;
        }
        if (maxX < coord.x) {
          maxX = coord.x;
        }
        if (maxY < coord.y) {
          maxY = coord.y;
        }
      }
    }
    final topLeft = Coordinate(minX - buffer, minY);
    final bottomRight = Coordinate(maxX + buffer, maxY);
    return Dimens(topLeft, bottomRight);
  }
}

int manhattenDistance(Coordinate a, Coordinate b) {
  return (a.x - b.x).abs() + (a.y - b.y).abs();
}

int maxItem(List<int> items) {
  assert(items.length >= 1);
  int max = items[0];
  items.forEach((element) {
    if (element > max) {
      max = element;
    }
  });
  return max;
}

List<int> manhattanDistances(Input input) {
  return input.map((pair) {
    return manhattenDistance(pair.first, pair.second);
  }).toList();
}
