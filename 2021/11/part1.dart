import 'dart:collection';

import 'package:equatable/equatable.dart';

import '../utils.dart';

final FLASH_THRESHOLD = 10;

class Coord extends Equatable {
  final int row;
  final int col;

  Coord(this.row, this.col);

  @override
  List<Object?> get props => [row * 100000, col];

  @override
  String toString() {
    return 'Coord($row, $col)';
  }
}

Future<List<List<int>>> parseInput() async {
  final inputLines = readFile('11/input');
  final inputLineList = await inputLines.toList();
  return inputLineList
      .map((line) => line.split('').map((char) => int.parse(char)).toList())
      .toList();
}

List<List<int>> step(List<List<int>> input) {
  return input
      .map((line) => line.map((element) => element + 1).toList())
      .toList();
}

bool validCoord(List<List<int>> input, int row, int col) {
  return row >= 0 && col >= 0 && row < input.length && col < input[0].length;
}

List<Coord> flash(List<List<int>> input, Coord coord) {
  assert(input[coord.row][coord.col] >= FLASH_THRESHOLD);
  input[coord.row][coord.col] = 0;
  List<Coord> shouldReflash = [];
  List.generate(3, (rowInc) {
    final rowIdx = coord.row - 1 + rowInc;
    List.generate(3, (colInc) {
      final colIdx = coord.col - 1 + colInc;
      final nextCoord = Coord(rowIdx, colIdx);
      if (validCoord(input, rowIdx, colIdx) && nextCoord != coord) {
        input[rowIdx][colIdx] += 1;
        if (input[rowIdx][colIdx] >= FLASH_THRESHOLD) {
          shouldReflash.add(nextCoord);
        }
      }
    });
  });
  return shouldReflash;
}

int _runAfterStep(List<List<int>> input) {
  Queue<Coord> toFlash = Queue();
  input.asMap().forEach((rowIdx, row) {
    row.asMap().forEach((colIdx, value) {
      if (value >= FLASH_THRESHOLD) {
        toFlash.add(Coord(rowIdx, colIdx));
      }
    });
  });

  List<Coord> toReset = [];
  while (toFlash.isNotEmpty) {
    final flashCoord = toFlash.removeFirst();
    if (input[flashCoord.row][flashCoord.col] >= FLASH_THRESHOLD) {
      toReset.add(flashCoord);
      toFlash.addAll(flash(input, flashCoord));
    }
  }

  toReset.forEach((coord) {
    input[coord.row][coord.col] = 0;
  });

  return toReset.length;
}

void printBoard(List<List<int>> input) {
  input.forEach((line) {
    print(line.join(''));
  });
  print('');
}

void main() async {
  List<List<int>> inputLines = await parseInput();

  /// Step N times
  final stepCount = 100;
  int flashCount = 0;
  List.generate(stepCount, (_) {
    inputLines = step(inputLines);
    flashCount += _runAfterStep(inputLines);
    printBoard(inputLines);
  });

  print(flashCount);
}
