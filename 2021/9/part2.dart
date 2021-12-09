import 'dart:collection';

import 'package:equatable/equatable.dart';

import './part1.dart';

class Coord extends Equatable {
  final int row;
  final int col;
  final int value;

  Coord(this.row, this.col, this.value);

  @override
  List<Object?> get props => [row * 100000, col];

  @override
  String toString() {
    return 'Coord($row, $col, $value)';
  }

  Coord? getTop(List<List<int>> input) {
    if (row == 0) return null;
    final nextValue = input[row - 1][col];
    return Coord(row - 1, col, nextValue);
  }

  Coord? getBottom(List<List<int>> input) {
    if (row == input.length - 1) return null;
    final nextValue = input[row + 1][col];
    return Coord(row + 1, col, nextValue);
  }

  Coord? getLeft(List<List<int>> input) {
    if (col == 0) return null;
    final nextValue = input[row][col - 1];
    return Coord(row, col - 1, nextValue);
  }

  Coord? getRight(List<List<int>> input) {
    if (col == input[0].length - 1) return null;
    final nextValue = input[row][col + 1];
    return Coord(row, col + 1, nextValue);
  }
}

List<Coord> getLowPoints(List<List<int>> input) {
  final List<Coord> lowPoints = [];
  input.asMap().forEach((rowIndex, row) {
    row.asMap().forEach((colIndex, point) {
      if (isLowPoint(input, rowIndex, colIndex)) {
        lowPoints.add(Coord(rowIndex, colIndex, point));
      }
    });
  });
  return lowPoints;
}

int getBasinSize(List<List<int>> input, Coord lowPoint) {
  final List<Coord> scanned = [];
  final Queue<Coord> queue = Queue.of([lowPoint]);
  int basinSize = 0;
  while (queue.length > 0) {
    final queueCoord = queue.removeFirst();
    basinSize++;
    scanned.add(queueCoord);

    final checkAndAdd = (Coord? nextCoord) {
      if (nextCoord != null &&
          nextCoord.value != 9 &&
          !scanned.contains(nextCoord) &&
          !queue.contains(nextCoord) &&
          nextCoord.value > queueCoord.value) {
        queue.add(nextCoord);
      }
    };

    /// Scan each of the four directions
    final top = queueCoord.getTop(input);
    checkAndAdd(top);
    final left = queueCoord.getLeft(input);
    checkAndAdd(left);
    final bottom = queueCoord.getBottom(input);
    checkAndAdd(bottom);
    final right = queueCoord.getRight(input);
    checkAndAdd(right);
  }

  return basinSize;
}

void main() async {
  final inputLines = await parseInput();
  final lowPoints = getLowPoints(inputLines);

  int curIdx = 0;
  final basinSizes = lowPoints.map((point) {
    curIdx++;
    // print('$point $curIdx/${lowPoints.length}');
    return getBasinSize(inputLines, point);
  }).toList();
  basinSizes.sort((a, b) => b.compareTo(a));

  /// What do you get if you multiply together the sizes of the three largest basins?
  final threeLargestMult = basinSizes[0] * basinSizes[1] * basinSizes[2];
  print(threeLargestMult);
}
