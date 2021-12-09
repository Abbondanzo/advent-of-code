import '../utils.dart';
import './part1.dart';

void main() async {
  final lines = readFile('4/input');
  final lineList = await lines.toList();

  final calls = parseCalls(lineList);
  final boards = parseBoards(lineList);

  int? lastCall = null;
  BingoBoard? lastWinner = null;
  List<BingoBoard> winningBoards = [];

  for (var i = 0; i < calls.length; i++) {
    final call = calls[i];
    final boardsCopy = [...boards];
    lastCall = call;
    boardsCopy.forEach((board) {
      if (board.markNumber(call)) {
        boards.remove(board);
        winningBoards.add(board);
        lastWinner = board;
      }
    });

    if (boards.length == 0) {
      break;
    }
  }

  final finalScore = lastWinner!.unmarkedNumberSum() * lastCall!;
  print('The final score is ${finalScore}');
}
