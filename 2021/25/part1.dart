import '../utils.dart';
import './parse.dart';

Coordinate nextCoord(
    bool east, int rowSize, int colSize, Coordinate currentCoord) {
  final dx = east ? 1 : 0;
  final dy = !east ? 1 : 0;
  final nextX = (currentCoord.x + dx) % colSize;
  final nextY = (currentCoord.y + dy) % rowSize;
  return Coordinate(nextX, nextY);
}

void main() async {
  final input = await parseInput('25/input');

  Set<Coordinate> currentEast = input.state.entries
      .where((element) => element.value == '>')
      .map((e) => e.key)
      .toSet();
  Set<Coordinate> currentSouth = input.state.entries
      .where((element) => element.value == 'v')
      .map((e) => e.key)
      .toSet();

  int step = 0;

  while (true) {
    step++;

    int numMoves = 0;

    final nextEast = Set<Coordinate>();
    currentEast.forEach((element) {
      final next = nextCoord(true, input.rowSize, input.colSize, element);
      if (!currentEast.contains(next) && !currentSouth.contains(next)) {
        numMoves++;
        nextEast.add(next);
      } else {
        nextEast.add(element);
      }
    });
    currentEast = nextEast;

    final nextSouth = Set<Coordinate>();
    currentSouth.forEach((element) {
      final next = nextCoord(false, input.rowSize, input.colSize, element);
      if (!currentEast.contains(next) && !currentSouth.contains(next)) {
        numMoves++;
        nextSouth.add(next);
      } else {
        nextSouth.add(element);
      }
    });
    currentSouth = nextSouth;

    if (numMoves == 0) {
      print(step);
      break;
    }
  }
}
