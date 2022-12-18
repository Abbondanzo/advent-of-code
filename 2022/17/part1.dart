import './shared.dart';
import '../utils.dart';

void purgeLowest(Set<Coordinate> frozenRocks) {
  // Find the lowest "high" point across columns, and purge below it
  List<int> highest = List.filled(7, 0);
  for (final rock in frozenRocks) {
    if (rock.y > highest[rock.x]) {
      highest[rock.x] = rock.y;
    }
  }
  highest.sort((a, b) => a.compareTo(b));
  final purgeBelow = highest.first - 5;
  if (purgeBelow == 0) return;
  frozenRocks.removeWhere((element) => element.y < purgeBelow);
}

void main() async {
  final input = await parseInput('17/input');
  int numRocks = 0;

  final Set<Coordinate> frozenRocks = {};
  final rockIterator = input.rockIterator().iterator;
  final moveIterator = input.moveIterator().iterator;

  while (numRocks < 2022) {
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

    // Purge the lowest from the set
    purgeLowest(frozenRocks);

    numRocks++;
  }

  // Height is 1-indexed, add 1
  print(highestPoint(frozenRocks) + 1);
}
