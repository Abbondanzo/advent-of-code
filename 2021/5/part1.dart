import 'package:equatable/equatable.dart';

import '../utils.dart';

class Point extends Equatable {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  List<Object?> get props => [x, y];

  static Point fromInput(String input) {
    final coords = input.split(',');
    assert(coords.length == 2);
    return Point(int.parse(coords[0]), int.parse(coords[1]));
  }
}

class Line {
  final Point a;
  final Point b;

  Line(this.a, this.b);

  static Line fromInput(String input) {
    final points = input.split(' -> ');
    assert(points.length == 2);
    return Line(Point.fromInput(points[0]), Point.fromInput(points[1]));
  }

  List<Point> getPoints(bool ignoreDiagonals) {
    // Horizontal lines
    if (a.y == b.y) {
      return _inclusiveRange(a.x, b.x).map((xCoord) {
        return Point(xCoord, a.y);
      }).toList();
    }
    // Vertical lines
    else if (a.x == b.x) {
      return _inclusiveRange(a.y, b.y).map((yCoord) {
        return Point(a.x, yCoord);
      }).toList();
    }
    // Needed to distinguish between part1 and part2
    else if (ignoreDiagonals) {
      return List.empty();
    }
    // 45-degree diagonals
    else {
      List<int> xCoords = _inclusiveRange(a.x, b.x);
      List<int> yCoords = _inclusiveRange(a.y, b.y);
      return xCoords
          .asMap()
          .map((index, xCoord) {
            return MapEntry(index, Point(xCoord, yCoords[index]));
          })
          .values
          .toList();
    }
  }

  /// Given two numbers, returns a list of numbers between those numbers
  /// including those numbers. If the first value is greater than the second,
  /// the list increments down by 1. Otherwise, it increments up by 1.
  List<int> _inclusiveRange(int a, int b) {
    final count = (a - b).abs() + 1;
    return List.generate(count, (index) {
      return a < b ? a + index : a - index;
    });
  }
}

void main() async {
  final inputLines = readFile('5/input');
  final inputLineList = await inputLines.toList();

  final lines = inputLineList.map((line) => Line.fromInput(line));

  final pointMap = Map<Point, int>();
  lines.forEach((line) {
    final pointsOnLine = line.getPoints(true);
    pointsOnLine.forEach((point) {
      pointMap.update(point, (value) => value + 1, ifAbsent: () => 1);
    });
  });

  // At how many points do at least two lines overlap?
  final overlapTwoCount = pointMap.values.where((value) => value >= 2).length;
  print('Number of two or more point overlaps $overlapTwoCount');
}
