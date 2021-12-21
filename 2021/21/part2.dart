import 'package:equatable/equatable.dart';

import '../utils.dart';

class GameState extends Equatable {
  final int curPlayerPos;
  final int nextPlayerPos;
  final int curPlayerScore;
  final int nextPlayerScore;

  GameState(this.curPlayerPos, this.nextPlayerPos, this.curPlayerScore,
      this.nextPlayerScore);

  GameState moveCurrentPlayer(int steps) {
    final newPlayerPos = GameState._nextPos(curPlayerPos, steps);
    final newPlayerScore = curPlayerScore + newPlayerPos;
    return GameState(
        nextPlayerPos, newPlayerPos, nextPlayerScore, newPlayerScore);
  }

  static int _nextPos(int curPos, int steps) {
    return (((curPos - 1) + steps) % 10) + 1;
  }

  @override
  List<Object?> get props =>
      [curPlayerPos, nextPlayerPos, curPlayerScore, nextPlayerScore];

  @override
  String toString() {
    return '{ur: {pos: $curPlayerPos, score: $curPlayerScore}, next: {pos: $nextPlayerPos, score: $nextPlayerScore}}';
  }
}

class WinPair {
  final int player1Wins;
  final int player2Wins;

  WinPair(this.player1Wins, this.player2Wins);

  int get max {
    return player1Wins > player2Wins ? player1Wins : player2Wins;
  }

  @override
  String toString() {
    return '[$player1Wins, $player2Wins]';
  }
}

void main(List<String> args) {
  Stopwatch stopwatch = new Stopwatch()..start();

  final Map<GameState, WinPair> pairings = Map();

  WinPair getWinConditions(GameState gameState) {
    if (pairings[gameState] == null) {
      // Generate winners
      if (gameState.curPlayerScore >= 21) {
        return WinPair(1, 0);
      }
      if (gameState.nextPlayerScore >= 21) {
        return WinPair(0, 1);
      }
      // Roll the die three times
      int currentPlayerWins = 0;
      int nextPlayerWins = 0;

      for (int roll1 in range(1, 4)) {
        for (int roll2 in range(1, 4)) {
          for (int roll3 in range(1, 4)) {
            final steps = roll1 + roll2 + roll3;
            final nextGameState = gameState.moveCurrentPlayer(steps);
            final nextWins = getWinConditions(nextGameState);

            currentPlayerWins += nextWins.player2Wins;
            nextPlayerWins += nextWins.player1Wins;
          }
        }
      }

      pairings[gameState] = WinPair(currentPlayerWins, nextPlayerWins);
    }
    return pairings[gameState]!;
  }

  final startingGameState = GameState(7, 6, 0, 0);
  final winConditions = getWinConditions(startingGameState);

  /// Find the player that wins in more universes; in how many universes does that player win?
  print(winConditions.max);

  print('executed in ${stopwatch.elapsed.inMilliseconds}ms');
}
