import './shared.dart';
import '../utils.dart';

Set<Coordinate> shiftDown(Set<Coordinate> frozenRocks, int by) {
  final Set<Coordinate> newSet = {};
  for (final coord in frozenRocks) {
    newSet.add(Coordinate(coord.x, coord.y - by));
  }
  return newSet;
}

bool hasPattern(Set<Coordinate> frozenRocks) {
  final totalHeight = highestPoint(frozenRocks) + 1;
  if (totalHeight % 2 != 0) return false;
  final offset = totalHeight ~/ 2;
  final Set<Coordinate> bottomSet = {};
  final Set<Coordinate> topSet = {};
  for (final coord in frozenRocks) {
    if (coord.y >= offset) {
      topSet.add(coord);
    } else {
      bottomSet.add(coord);
    }
  }
  final shiftedTopSet = shiftDown(frozenRocks, offset);
  return bottomSet.difference(shiftedTopSet).isEmpty;
}

void main() async {
  final input = await parseInput('17/demo');

  int numRocks = 0;
  final Set<Coordinate> frozenRocks = {};
  final rockIterator = input.rockIterator().iterator;
  final moveIterator = input.moveIterator().iterator;

  int lastHeight = 0;

  while (numRocks < 520) {
    Coordinate origin = Coordinate(2, highestPoint(frozenRocks) + 4);
    rockIterator.moveNext();
    final rock = rockIterator.current;

    // Move that ~bus~ rock!
    while (true) {
      moveIterator.moveNext();
      final shouldMoveLeft = moveIterator.current;
      if (shouldMoveLeft) {
        origin = moveLeft(rock, origin, frozenRocks);
      } else {
        origin = moveRight(rock, origin, frozenRocks);
      }
      if (canMoveDown(rock, origin, frozenRocks)) {
        origin = Coordinate(origin.x, origin.y - 1);
      } else {
        frozenRocks.addAll(rock.offset(origin));
        break;
      }
    }

    final currentHeight = highestPoint(frozenRocks);

    if (numRocks % 1000 == 0) {
      print("Ongoing $numRocks");
    }

    if (hasPattern(frozenRocks)) {
      print(numRocks);
      break;
    }

    lastHeight = currentHeight;

    numRocks++;
  }
}
