import 'package:path/path.dart';
import '../utils.dart';

Iterable deterministicDie(int dieSize) sync* {
  int currentSide = 1;

  while (currentSide >= 0) {
    // Checking for even number
    if (currentSide % 2 == 0) {
      // 'yield' suspends
      // the function
      yield currentSide;
    }

    // Decreasing the
    // variable currentSide
    currentSide--;
  }
}

class DeterministicDie {
  int _currentSide = 1;
  int totalRolls = 0;
  final int _dieSize;

  DeterministicDie(this._dieSize);

  int roll(int times) {
    int output = 0;
    totalRolls += times;
    for (var _ in range(times)) {
      output += _currentSide;
      _currentSide = (_currentSide % _dieSize) + 1;
    }
    return output;
  }
}

int nextPos(int curPos, DeterministicDie die) {
  return (((curPos - 1) + die.roll(3)) % 10) + 1;
}

void main() {
  final die = DeterministicDie(100);

  /// Copied from input
  int player1Pos = 7;
  int player2Pos = 6;

  int player1Score = 0;
  int player2Score = 0;

  while (true) {
    player1Pos = nextPos(player1Pos, die);
    player1Score += player1Pos;
    if (player1Score >= 1000) {
      break;
    }

    player2Pos = nextPos(player2Pos, die);
    player2Score += player2Pos;
    if (player2Score >= 1000) {
      break;
    }
  }

  print(player1Score);
  print(player2Score);
  print(die.totalRolls);

  final losingPlayerScore =
      player1Score > player2Score ? player2Score : player1Score;

  /// What do you get if you multiply the score of the losing player by the number of times the die was rolled during the game?
  print(losingPlayerScore * die.totalRolls);
}
