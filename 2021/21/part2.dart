import 'package:equatable/equatable.dart';

import '../utils.dart';

class GameState extends Equatable {
  final int player1Pos;
  final int player2Pos;
  final int player1Score;
  final int player2Score;

  GameState(
      this.player1Pos, this.player2Pos, this.player1Score, this.player2Score);

  GameState movePlayer1(int steps) {
    final nextPlayer1Pos = _nextPos(player1Pos, steps);
    return GameState(nextPlayer1Pos, player2Pos, player1Score + nextPlayer1Pos,
        player2Score);
  }

  GameState movePlayer2(int steps) {
    final nextPlayer2Pos = _nextPos(player2Pos, steps);
    return GameState(player1Pos, nextPlayer2Pos, player1Score,
        player2Score + nextPlayer2Pos);
  }

  static int _nextPos(int curPos, int steps) {
    return (((curPos - 1) + steps) % 10) + 1;
  }

  @override
  List<Object?> get props =>
      [player1Pos, player2Pos, player1Score, player2Score];

  @override
  String toString() {
    return '{p1: {pos: $player1Pos, score: $player1Score}, p2: {pos: $player2Pos, score: $player2Score}}';
  }
}

class WinPair {
  final int player1Wins;
  final int player2Wins;

  WinPair(this.player1Wins, this.player2Wins);

  WinPair operator +(WinPair other) {
    return WinPair(
        player1Wins + other.player1Wins, player2Wins + other.player2Wins);
  }

  WinPair operator *(WinPair other) {
    return WinPair(
        player1Wins * other.player1Wins, player2Wins * other.player2Wins);
  }

  @override
  String toString() {
    return '[$player1Wins, $player2Wins]';
  }
}

void main(List<String> args) {
  // Stopwatch stopwatch = new Stopwatch()..start();
  // int n = 0;
  // Iterable.generate(341960390180808, (index) => index).forEach((_) {
  //   n++;
  // });

  // print('executed in ${stopwatch.elapsed.inMilliseconds}ms');
  // print(n);

  final startingGameState = GameState(4, 8, 0, 0);

  final Map<GameState, WinPair> pairings = Map();

  WinPair getWinConditions(GameState gameState) {
    if (pairings[gameState] == null) {
      int player1Wins = 0;
      int player2Wins = 0;
      // Generate winners
      if (gameState.player1Score >= 21) {
        player1Wins = 1;
      }
      // Roll the die three times
      else {
        for (int roll1 in range(1, 4)) {
          for (int roll2 in range(1, 4)) {
            for (int roll3 in range(1, 4)) {
              final nextGameState =
                  gameState.movePlayer1(roll1 + roll2 + roll3);
              player1Wins += getWinConditions(nextGameState).player1Wins;
            }
          }
        }
      }
      if (gameState.player2Score >= 21) {
        player2Wins = 1;
      } else {
        for (int roll1 in range(1, 4)) {
          for (int roll2 in range(1, 4)) {
            for (int roll3 in range(1, 4)) {
              final nextGameState =
                  gameState.movePlayer2(roll1 + roll2 + roll3);
              player2Wins += getWinConditions(nextGameState).player2Wins;
            }
          }
        }
      }
      pairings[gameState] = WinPair(player1Wins, player2Wins);
    }
    return pairings[gameState]!;
  }

  // print(getWinConditions(GameState(1, 1, 19, 19)));

  // for (int player1Pos in range(10)) {
  //   for (int player2Pos in range(10)) {
  //     for (int player1Score in range(20)) {
  //       for (int player2Score in range(20)) {
  //         final gameState = GameState(player1Pos + 1, player2Pos + 1,
  //             20 - player1Score, 20 - player2Score);
  //         print(gameState);
  //         getWinConditions(gameState);
  //       }
  //     }
  //   }
  // }

  print(getWinConditions(startingGameState));
}
