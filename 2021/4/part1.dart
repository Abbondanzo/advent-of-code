import 'dart:io';

import 'package:equatable/equatable.dart';
import '../utils.dart';

class BingoBoard extends Equatable {
  // A list of rows of numbers (i.e. index 0 is the top row);
  final List<List<int>> _numbers;
  final List<List<bool>> _markedNumbers;

  BingoBoard(this._numbers, this._markedNumbers);

  static BingoBoard fromLines(List<String> lines) {
    assert(lines.length == 5);
    final numbers = lines.map((line) {
      final rowNumbers = line
          .split(' ')
          .where((e) => e != '')
          .map((e) => int.parse(e))
          .toList();
      assert(rowNumbers.length == 5);
      return rowNumbers;
    }).toList();
    final markedNumbers = List.generate(5, (_) => List.filled(5, false));
    return BingoBoard(numbers, markedNumbers);
  }

  bool markNumber(int number) {
    bool causedWin = false;
    _numbers.asMap().forEach((rowIndex, numberRow) {
      numberRow.asMap().forEach((colIndex, boardNumber) {
        if (boardNumber == number) {
          _markedNumbers[rowIndex][colIndex] = true;
          causedWin = _causedWin(rowIndex, colIndex);
        }
      });
    });
    return causedWin;
  }

  bool _causedWin(int rowIndex, int colIndex) {
    return _markedNumbers[rowIndex].every((element) => element) ||
        _markedNumbers.map((row) => row[colIndex]).every((element) => element);
  }

  int unmarkedNumberSum() {
    int sum = 0;
    _markedNumbers.asMap().forEach((rowIndex, markedRow) {
      markedRow.asMap().forEach((colIndex, marked) {
        if (!marked) {
          sum += _numbers[rowIndex][colIndex];
        }
      });
    });
    return sum;
  }

  @override
  List<Object?> get props => [_numbers, _markedNumbers];

  List<int> get numbers => _numbers.fold([], (previousValue, element) {
        previousValue.addAll(element);
        return previousValue;
      });

  @override
  String toString() {
    String output = '';
    _numbers.asMap().forEach((rowIndex, numberRow) {
      List<String> rowStr = [];
      numberRow.asMap().forEach((colIndex, boardNumber) {
        String numStr = '';
        if (boardNumber < 10) {
          numStr += ' ';
        }
        numStr += boardNumber.toString();
        final marked = _markedNumbers[rowIndex][colIndex];
        if (marked) {
          numStr += '-';
        }
        rowStr.add(numStr);
      });
      output += rowStr.join(' ');
      output += '\n';
    });
    return output;
  }
}

List<int> parseCalls(List<String> lines) {
  return lines[0].split(',').map((str) => int.parse(str)).toList();
}

List<BingoBoard> parseBoards(List<String> lines) {
  List<BingoBoard> boards = [];
  List<String> boardLines = [];
  lines.skip(2).forEach((element) {
    if (element == '') {
      assert(boardLines.length == 5);
      boards.add(BingoBoard.fromLines(boardLines));
      boardLines = [];
    } else {
      boardLines.add(element);
    }
  });

  assert(boardLines.length == 5);
  boards.add(BingoBoard.fromLines(boardLines));

  return boards;
}

void main() async {
  final lines = readFile('4/input');
  final lineList = await lines.toList();

  final calls = parseCalls(lineList);
  final boards = parseBoards(lineList);

  for (var i = 0; i < calls.length; i++) {
    int call = calls[i];
    boards.forEach((board) {
      if (board.markNumber(call)) {
        final finalScore = board.unmarkedNumberSum() * call;
        print(board.toString());
        print('The final score is ${finalScore}');
        exit(0);
      }
    });
  }
}
