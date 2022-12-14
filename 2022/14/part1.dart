import './shared.dart';
import '../utils.dart';

Coordinate? findSpot(Board board) {
  Coordinate cur = Coordinate(500, 0);
  while (true) {
    if (cur.y > board.largestY) {
      return null;
    }
    final directlyBelow = Coordinate(cur.x, cur.y + 1);
    if (!board.contains(directlyBelow)) {
      cur = directlyBelow;
      continue;
    }
    // Check down-left
    final downLeft = Coordinate(cur.x - 1, cur.y + 1);
    if (!board.contains(downLeft)) {
      cur = downLeft;
      continue;
    }
    // Check down-right
    final downRight = Coordinate(cur.x + 1, cur.y + 1);
    if (!board.contains(downRight)) {
      cur = downRight;
      continue;
    }
    return cur;
  }
}

void main() async {
  final input = await parseInput('14/input');
  final board = Board.createBoard(input);

  Coordinate? spot = findSpot(board);
  while (spot != null) {
    if (board.sand.contains(spot)) {
      break;
    }
    board.sand.add(spot);
    spot = findSpot(board);
  }

  print(board.sand.length);
}
