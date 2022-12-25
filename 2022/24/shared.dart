import "../utils.dart";

typedef Blizzard = Pair<Coordinate, String>;

class BoardState {
  final int height;
  final int width;
  final Set<Blizzard> blizzards;

  BoardState(this.height, this.width, this.blizzards);

  BoardState nextState() {
    final newBlizzards = blizzards.map(_moveBlizzard);
    return BoardState(height, width, newBlizzards.toSet());
  }

  Blizzard _moveBlizzard(Blizzard blizzard) {
    final direction = blizzard.second;
    final curSpot = blizzard.first;
    switch (direction) {
      case "<":
        final newX = curSpot.x == 1 ? width - 2 : curSpot.x - 1;
        return Pair(Coordinate(newX, curSpot.y), direction);
      case "^":
        final newY = curSpot.y == 1 ? height - 2 : curSpot.y - 1;
        return Pair(Coordinate(curSpot.x, newY), direction);
      case ">":
        final newX = curSpot.x == width - 2 ? 1 : curSpot.x + 1;
        return Pair(Coordinate(newX, curSpot.y), direction);
      case "v":
        final newY = curSpot.y == height - 2 ? 1 : curSpot.y + 1;
        return Pair(Coordinate(curSpot.x, newY), direction);
    }
    throw Error();
  }
}

List<Coordinate> getMoves(Coordinate curSpot, BoardState board) {
  List<Coordinate> moves = [];
  bool isEmpty(Coordinate spot) {
    return board.blizzards.every((element) => element.first != spot);
  }

  // Stay put
  if (isEmpty(curSpot)) {
    moves.add(curSpot);
  }
  // Starter
  if (curSpot.y == 0) {
    final down = Coordinate(curSpot.x, curSpot.y + 1);
    if (isEmpty(down)) {
      moves.add(down);
    }
    return moves;
  }
  if (curSpot.y == board.height - 1) {
    final up = Coordinate(curSpot.x, curSpot.y - 1);
    if (isEmpty(up)) {
      moves.add(up);
    }
    return moves;
  }
  // Left
  final left = Coordinate(curSpot.x - 1, curSpot.y);
  if (curSpot.x > 1 && isEmpty(left)) {
    moves.add(left);
  }
  // Right
  final right = Coordinate(curSpot.x + 1, curSpot.y);
  if (curSpot.x < board.width - 2 && isEmpty(right)) {
    moves.add(right);
  }
  // Up
  final up = Coordinate(curSpot.x, curSpot.y - 1);
  if (curSpot.y > 1 && isEmpty(up)) {
    moves.add(up);
  }
  // Down
  final down = Coordinate(curSpot.x, curSpot.y + 1);
  if (curSpot.y < board.height - 2 && isEmpty(down)) {
    moves.add(down);
  }
  return moves;
}

int rankSpot(Coordinate spot, Coordinate goal) {
  return goal.x - spot.x + goal.y - spot.y;
}

Pair<BoardState, int> timeToGoal(
    Coordinate goal, Coordinate startSpot, BoardState state) {
  List<Pair<int, Coordinate>> queue = [];
  queue.add(Pair(0, startSpot));
  List<BoardState> states = [state];
  Set<String> visited = {};
  List<Map<Coordinate, Coordinate>> path = [];

  int depth = 0;
  while (queue.isNotEmpty) {
    final item = queue.removeAt(0);
    final time = item.first;

    if (time > depth) {
      depth = time;
      // Sort by Manhattan distance + time elapsed
      queue.sort((a, b) => (a.first + rankSpot(a.second, goal))
          .compareTo(b.first + rankSpot(b.second, goal)));
    }

    if (item.second == goal) {
      return Pair(states[time], time);
    }

    if (time >= states.length) {
      for (int i in range(states.length, time + 1)) {
        states.add(states[i - 1].nextState());
      }
    }

    if (time >= path.length - 1) {
      for (int _ in range(path.length, time + 2)) {
        path.add({});
      }
    }

    final moves = getMoves(item.second, states[time]);
    for (final move in moves) {
      final nextItem = Pair(time + 1, move);
      final key = "$nextItem";
      if (!visited.contains(key)) {
        visited.add(key);
        queue.add(nextItem);
        path[time + 1][move] = item.second;
      }

      // if (!visited.containsKey(move) || visited[move]! > newTime) {
      //   visited[move] = newTime;
      //   queue.add(Pair(newTime, move));
      // }
    }
  }

  throw Error();
}

Future<BoardState> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  assert(inputLineList.length > 0);
  final Set<Blizzard> blizzards = {};
  int width = inputLineList[0].length;
  int height = inputLineList.length;
  final validChars = ["<", "^", ">", "v"];
  for (int y in range(inputLineList.length)) {
    final row = inputLineList[y].split("");
    for (int x in range(row.length)) {
      final char = row[x];
      if (validChars.contains(char)) {
        blizzards.add(Pair(Coordinate(x, y), char));
      }
    }
  }
  return BoardState(height, width, blizzards);
}
