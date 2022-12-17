import './shared.dart';
import '../utils.dart';

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

void purgeLowest(Set<Coordinate> frozenRocks) {
  // Find the lowest "high" point across columns, and purge below it
  List<int> highest = List.filled(7, 0);
  for (final rock in frozenRocks) {
    if (rock.y > highest[rock.x]) {
      highest[rock.x] = rock.y;
    }
  }
  highest.sort((a, b) => a.compareTo(b));
  final purgeBelow = highest.first;
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
