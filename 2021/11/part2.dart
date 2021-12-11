import 'dart:collection';

import '../utils.dart';
import './part1.dart';

bool _runAfterStep(List<List<int>> input) {
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

  return toReset.length == input.length * input[0].length;
}

void main() async {
  List<List<int>> inputLines = await parseInput();

  /// Keep incrementing step count until done
  int stepCount = 0;
  while (true) {
    stepCount++;
    inputLines = step(inputLines);
    final inSync = _runAfterStep(inputLines);
    if (inSync) {
      break;
    }
  }

  /// What is the first step during which all octopuses flash?
  print(stepCount);
}
