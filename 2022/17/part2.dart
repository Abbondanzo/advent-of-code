import './shared.dart';
import '../utils.dart';

void main() async {
  final input = await parseInput('17/input');

  int numRocks = 0;
  final Set<Coordinate> frozenRocks = {};
  final rockIterator = input.rockIterator().iterator;
  final moveIterator = input.moveIterator().iterator;

  int lastHeight = 0;

  while (numRocks < input.rawCommands.length * 25) {
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

    if (numRocks % input.rawCommands.length == 0) {
      print(
          "${currentHeight - lastHeight}, $numRocks ${highestPoint(frozenRocks)}");
    }

    // Observations on the demo input:
    // 280 rocks, 424 height
    // (1000000000000 / 280).floor() = 3571428571
    // (1000000000000 % 280) = 120
    // (1000000000000 - 240) = 999999999760
    // (999999999760 / 280).floor() = 3571428570
    // (999999999760 % 280) = 160
    // growth rate = [63, 59, 59, 59, 64, 60, 60]
    // = 368 + (3571428570 * 424) + 63 + 59 + 59 + 59
    // = 368 + 1514285713680 + 63 + 59 + 59 + 59
    // = 1514285714288, the answer

    lastHeight = currentHeight;

    purgeLowest(frozenRocks);

    numRocks++;
  }
}
