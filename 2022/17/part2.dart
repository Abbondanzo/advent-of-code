import 'package:equatable/equatable.dart';

import './shared.dart';
import '../utils.dart';

class InputGameState extends Equatable {
  final List<int> tops;
  final int pieceIndex;
  final int commandIndex;

  InputGameState(List<int> tops, this.pieceIndex, this.commandIndex)
      : this.tops = _normalizeTops(tops);

  @override
  List<Object?> get props => [tops, pieceIndex, commandIndex];

  @override
  String toString() {
    return "InputGameState($pieceIndex, $commandIndex) - $tops";
  }

  static List<int> _normalizeTops(List<int> tops) {
    int minY = tops[0];
    for (final bottom in tops) {
      if (bottom < minY) {
        minY = bottom;
      }
    }
    return tops.map((bottom) => bottom - minY).toList();
  }
}

List<int> getTops(Set<Coordinate> frozenRocks) {
  final List<int> highestY = List.filled(7, 0);
  for (int i in range(7)) {
    for (final rock in frozenRocks) {
      if (rock.x == i) {
        if (highestY[rock.x] < rock.y) {
          highestY[rock.x] = rock.y;
        }
      }
    }
  }
  return highestY;
}

class BoardGameState {
  final int numRocks;
  final int height;

  BoardGameState(this.numRocks, this.height);

  @override
  String toString() {
    return "BoardGameState($numRocks, $height)";
  }
}

void main() async {
  final input = await parseInput('17/input');

  final int NUM_ROCKS = 1000000000000;

  int numRocks = 0;
  final Set<Coordinate> frozenRocks = {};
  final rockIterator = input.rockIterator().iterator;
  final moveIterator = input.moveIterator().iterator;

  void addRock() {
    Coordinate origin = Coordinate(2, highestPoint(frozenRocks) + 4);
    rockIterator.moveNext();
    numRocks++;
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
  }

  final Map<InputGameState, BoardGameState> states = {};

  while (true) {
    addRock();
    purgeLowest(frozenRocks);

    final tops = getTops(frozenRocks);
    final pieceIndex = input.pieceIdx;
    final commandIndex = input.commandIdx;
    final state = InputGameState(tops, pieceIndex, commandIndex);

    // A repetition has been discovered
    if (states.containsKey(state)) {
      final boardState = states[state]!;
      final rocksPerIteration = numRocks - boardState.numRocks;
      final numIterations =
          (NUM_ROCKS - boardState.numRocks) ~/ rocksPerIteration;
      final remainingRocks = (NUM_ROCKS - boardState.numRocks) -
          (numIterations * rocksPerIteration);
      final heightPerIteration =
          (highestPoint(frozenRocks) + 1) - boardState.height;
      for (int _ in range(remainingRocks)) {
        addRock();
      }
      final totalHeight = highestPoint(frozenRocks) +
          1 +
          (heightPerIteration * (numIterations - 1));
      print(totalHeight);
      break;
    }

    states[state] = BoardGameState(numRocks, highestPoint(frozenRocks) + 1);
  }
}
