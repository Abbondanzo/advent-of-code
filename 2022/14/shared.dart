import '../utils.dart';

Future<List<List<Coordinate>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) {
    return line.split(" -> ").map((rawCoord) {
      final coords = rawCoord.split(",").map((el) => int.parse(el));
      assert(coords.length == 2);
      return Coordinate(coords.first, coords.last);
    }).toList();
  }).toList();
}

class Board {
  final Set<Coordinate> lines;
  final Set<Coordinate> sand;
  final int largestY;
  final int smallestX;
  final int largestX;

  Board(this.lines, this.sand, this.largestY, this.smallestX, this.largestX) {}

  bool contains(Coordinate coordinate) {
    return lines.contains(coordinate) || sand.contains(coordinate);
  }

  String toCondensedString() {
    return range(largestY + 1)
        .map((y) => range(smallestX, largestX + 1).map((x) {
              if (x == 500 && y == 0) {
                return "+";
              } else if (lines.contains(Coordinate(x, y))) {
                return "#";
              } else if (sand.contains(Coordinate(x, y))) {
                return "o";
              } else {
                return ".";
              }
            }).join(""))
        .join("\n");
  }

  @override
  String toString() {
    return range(largestY + 3)
        .map((y) => range(500 - largestY - 3, 500 + largestY + 3).map((x) {
              if (x == 500 && y == 0) {
                return "+";
              } else if (lines.contains(Coordinate(x, y))) {
                return "#";
              } else if (sand.contains(Coordinate(x, y))) {
                return "o";
              } else {
                return ".";
              }
            }).join(""))
        .join("\n");
  }

  static Board createBoard(List<List<Coordinate>> paths) {
    int largestY = 0;
    int smallestX = 500;
    int largestX = 500;
    final Set<Coordinate> lines = new Set();
    for (List<Coordinate> path in paths) {
      Coordinate? prev;
      for (Coordinate point in path) {
        if (prev == null) {
          prev = point;
        } else {
          assert(prev.x == point.x || prev.y == point.y);
          final xStep = prev.x > point.x
              ? -1
              : prev.x < point.x
                  ? 1
                  : 0;
          final yStep = prev.y > point.y
              ? -1
              : prev.y < point.y
                  ? 1
                  : 0;
          final distance = (prev.x - point.x).abs() + (prev.y - point.y).abs();
          for (int i in range(distance + 1)) {
            final newX = prev.x + (xStep * i);
            final newY = prev.y + (yStep * i);
            lines.add(new Coordinate(newX, newY));
            if (newY > largestY) {
              largestY = newY;
            }
            if (newX > largestX) {
              largestX = newX;
            }
            if (newX < smallestX) {
              smallestX = newX;
            }
          }
          prev = point;
        }
      }
    }
    return Board(lines, new Set(), largestY, smallestX, largestX);
  }
}
