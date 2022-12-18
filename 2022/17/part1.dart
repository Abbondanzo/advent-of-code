import './shared.dart';
import '../utils.dart';

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
