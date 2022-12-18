import '../utils.dart';

class Input {
  final List<String> rawCommands;
  int _pieceIdx = 0;
  int _commandIdx = 0;

  Input(this.rawCommands);

  Iterable<bool> moveIterator() sync* {
    while (true) {
      yield rawCommands[_commandIdx] == "<";
      _commandIdx++;
      if (_commandIdx >= rawCommands.length) {
        _commandIdx = 0;
      }
    }
  }

  Iterable<Rock> rockIterator() sync* {
    while (true) {
      yield Rock(_pieceIdx);
      _pieceIdx++;
      if (_pieceIdx > 4) {
        _pieceIdx = 0;
      }
    }
  }
}

class Rock {
  final int _index;
  // Origin is bottom-left
  final Set<Coordinate> points = {};

  Rock(this._index) {
    switch (_index) {
      case 0:
        points.add(Coordinate(0, 0));
        points.add(Coordinate(1, 0));
        points.add(Coordinate(2, 0));
        points.add(Coordinate(3, 0));
        break;
      case 1:
        points.add(Coordinate(0, 1));
        // points.add(Coordinate(1, 1)); ignore the middle
        points.add(Coordinate(2, 1));
        points.add(Coordinate(1, 0));
        points.add(Coordinate(1, 2));
        break;
      case 2:
        points.add(Coordinate(0, 0));
        points.add(Coordinate(1, 0));
        points.add(Coordinate(2, 0));
        points.add(Coordinate(2, 1));
        points.add(Coordinate(2, 2));
        break;
      case 3:
        points.add(Coordinate(0, 0));
        points.add(Coordinate(0, 1));
        points.add(Coordinate(0, 2));
        points.add(Coordinate(0, 3));
        break;
      case 4:
        points.add(Coordinate(0, 0));
        points.add(Coordinate(0, 1));
        points.add(Coordinate(1, 0));
        points.add(Coordinate(1, 1));
        break;
      default:
        throw ErrorMessage("Unsupported rock idx $_index");
    }
  }

  Set<Coordinate> offset(Coordinate origin) {
    final Set<Coordinate> pts = {};
    for (final pt in points) {
      pts.add(Coordinate(pt.x + origin.x, pt.y + origin.y));
    }
    return pts;
  }

  @override
  String toString() {
    final List<List<String>> outputLines =
        List.generate(4, (_) => List.generate(4, (_) => "."));
    for (final point in points) {
      outputLines[3 - point.y][point.x] = "#";
    }
    return outputLines.map((line) => line.join("")).join("\n");
  }
}

bool collides(Rock rock, Coordinate origin, Set<Coordinate> frozenRocks) {
  final offsetHitPoints = rock.offset(origin);
  return frozenRocks.difference(offsetHitPoints).length != frozenRocks.length;
}

bool canMoveDown(Rock rock, Coordinate origin, Set<Coordinate> frozenRocks) {
  if (origin.y == 0) return false;
  final nextOrigin = Coordinate(origin.x, origin.y - 1);
  return !collides(rock, nextOrigin, frozenRocks);
}

Coordinate moveLeft(Rock rock, Coordinate origin, Set<Coordinate> frozenRocks) {
  if (origin.x == 0) return origin;
  final nextOrigin = Coordinate(origin.x - 1, origin.y);
  if (collides(rock, nextOrigin, frozenRocks)) {
    return origin;
  } else {
    return nextOrigin;
  }
}

Coordinate moveRight(
    Rock rock, Coordinate origin, Set<Coordinate> frozenRocks) {
  final nextOrigin = Coordinate(origin.x + 1, origin.y);
  final offsetHitPoints = rock.offset(nextOrigin);
  if (offsetHitPoints.any((element) => element.x > 6)) return origin;
  if (frozenRocks.difference(offsetHitPoints).length == frozenRocks.length) {
    return nextOrigin;
  } else {
    return origin;
  }
}

int highestPoint(Set<Coordinate> frozenRocks) {
  int highestY = -1;
  for (final rock in frozenRocks) {
    if (rock.y > highestY) {
      highestY = rock.y;
    }
  }
  return highestY;
}

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final rawInputLine = inputLineList[0];
  final commands = rawInputLine.split("");
  assert(commands.every((element) => element == "<" || element == ">"));
  return Input(commands);
}
