import '../utils.dart';

Future<List<Pair<String, int>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return inputLineList.map((line) {
    final rawChars = line.split(' ');
    assert(rawChars.length == 2);
    return Pair(rawChars[0], int.parse(rawChars[1]));
  }).toList();
}

class GameState {
  final List<Set<Coordinate>> tailSpots;
  Coordinate head;
  List<Coordinate> tails;

  GameState()
      : tailSpots = range(9).map((_) => {new Coordinate(0, 0)}).toList(),
        head = new Coordinate(0, 0),
        tails = range(9).map((_) => new Coordinate(0, 0)).toList();

  void handleCommand(String direction, int steps) {
    int stepX = 0;
    int stepY = 0;
    switch (direction) {
      case "R":
        stepX++;
        break;
      case "L":
        stepX--;
        break;
      case "U":
        stepY++;
        break;
      case "D":
        stepY--;
    }
    for (var _ in range(0, steps)) {
      head = Coordinate(head.x + stepX, head.y + stepY);
      _updateTails();
    }
  }

  void _updateTails() {
    for (int knot in range(tails.length)) {
      Coordinate prev;
      if (knot == 0) {
        prev = head;
      } else {
        prev = tails[knot - 1];
      }
      tails[knot] = _movePoint(prev, tails[knot]);
      tailSpots[knot].add(tails[knot]);
    }
  }

  Coordinate _movePoint(Coordinate h, Coordinate t) {
    // Same spot
    if (h.x == t.x && h.y == t.y) {
      return t;
    }
    // Touching
    else if ((h.x - t.x).abs() <= 1 && (h.y - t.y).abs() <= 1) {
      return t;
    }
    // Horizontal/vertical
    else if (h.x == t.x || h.y == t.y) {
      if (h.x == t.x) {
        int step = h.y > t.y ? -1 : 1;
        return Coordinate(t.x, h.y + step);
      } else {
        int step = h.x > t.x ? -1 : 1;
        return Coordinate(h.x + step, t.y);
      }
    }
    // Diagonal
    else {
      int xStep = h.x > t.x ? 1 : -1;
      int yStep = h.y > t.y ? 1 : -1;
      return Coordinate(t.x + xStep, t.y + yStep);
    }
  }
}

void main() async {
  final input = await parseInput('09/input');
  final gameState = new GameState();
  for (var instruction in input) {
    gameState.handleCommand(instruction.first, instruction.second);
  }
  print(gameState.tailSpots[gameState.tailSpots.length - 1].length);
}
