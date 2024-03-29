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
  final Set<Coordinate> tailSpots;
  Coordinate head;
  Coordinate tail;

  GameState()
      : tailSpots = new Set(),
        head = new Coordinate(0, 0),
        tail = new Coordinate(0, 0);

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
      _updateTail();
      // print("head");
      // print(head);
      // print(tail);
    }
  }

  void _updateTail() {
    // Same spot
    if (head.x == tail.x && head.y == tail.y) {
      tailSpots.add(tail);
    }
    // Touching
    else if ((head.x - tail.x).abs() <= 1 && (head.y - tail.y).abs() <= 1) {
      tailSpots.add(tail);
    }
    // Horizontal/vertical
    else if (head.x == tail.x || head.y == tail.y) {
      if (head.x == tail.x) {
        int step = head.y > tail.y ? -1 : 1;
        tail = Coordinate(tail.x, head.y + step);
      } else {
        int step = head.x > tail.x ? -1 : 1;
        tail = Coordinate(head.x + step, tail.y);
      }
      tailSpots.add(tail);
    }
    // Diagonal
    else {
      int xStep = head.x > tail.x ? 1 : -1;
      int yStep = head.y > tail.y ? 1 : -1;
      tail = Coordinate(tail.x + xStep, tail.y + yStep);
      tailSpots.add(tail);
    }
  }
}

void main() async {
  final input = await parseInput('09/input');
  final gameState = new GameState();
  for (var instruction in input) {
    // print(instruction);
    gameState.handleCommand(instruction.first, instruction.second);
  }
  print(gameState.tailSpots.length);
}
