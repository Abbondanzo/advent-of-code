import 'dart:math';

import './shared.dart';
import '../utils.dart';

final MAX_TIME = 32;

List<Pair<MaterialCounts, MaterialCounts>> bills(
    Blueprint blueprint, MaterialCounts materials, MaterialCounts robots) {
  List<Pair<MaterialCounts, MaterialCounts>> options = [];

  for (final i in range(blueprint.bills.length)) {
    final billIndex = blueprint.bills.length - i - 1;
    final bill = blueprint.bills[billIndex];
    final costs = bill.first;
    final canAfford = range(materials.list.length)
        .every((index) => materials.list[index] >= costs.list[index]);
    if (!canAfford) continue;
    final atMax = range(materials.list.length).every(
        (index) => materials.list[index] > blueprint.maxCosts.list[index]);
    if (atMax) continue;
    options.add(bill);
  }
  return options;
}

MaterialCounts update(MaterialCounts materials, MaterialCounts robots) {
  return materials + robots;
}

class GameState {
  final MaterialCounts materials;
  final MaterialCounts robots;

  GameState(this.materials, this.robots);

  @override
  String toString() {
    return "$materials $robots";
  }

  int potential(int timeRemaining) {
    final tries = (timeRemaining * (timeRemaining - 1)) ~/ 2;
    return materials.geode + (robots.geode * timeRemaining) + tries;
  }

  bool skip(Blueprint blueprint) {
    return range(materials.list.length).every(
        (index) => materials.list[index] >= blueprint.maxCosts.list[index]);
  }

  GameState doNothing() {
    MaterialCounts newMaterials = materials + robots;
    return GameState(newMaterials, robots);
  }

  List<Pair<MaterialCounts, MaterialCounts>> bills(Blueprint blueprint) {
    List<Pair<MaterialCounts, MaterialCounts>> options = [];

    for (final i in range(blueprint.bills.length)) {
      final billIndex = blueprint.bills.length - i - 1;
      final bill = blueprint.bills[billIndex];
      final costs = bill.first;
      final canAfford = range(materials.list.length)
          .every((index) => materials.list[index] >= costs.list[index]);
      if (!canAfford) continue;
      // final atMax = billIndex != 3 &&
      //     range(materials.list.length).every((index) =>
      //         materials.list[index] > blueprint.maxCosts.list[index]);
      // if (atMax) continue;
      options.add(bill);
    }
    return options;
  }
}

int evaluateState(Blueprint blueprint, GameState state) {
  List<Pair<int, GameState>> queue = [Pair(0, state)];
  Set<String> seen = {};

  int maxGeodes = 0;
  int curTime = 2;

  while (queue.isNotEmpty) {
    final item = queue.removeAt(0);
    final timeElapsed = item.first;
    if (timeElapsed > curTime) {
      curTime = timeElapsed;
      queue.sort((a, b) => b.second
          .potential(MAX_TIME - b.first)
          .compareTo(a.second.potential(MAX_TIME - a.first)));
      if (queue.length > 0) {
        final maxPotential =
            queue.first.second.potential(MAX_TIME - queue.first.first);
        queue.removeWhere(
            ((e) => e.second.potential(MAX_TIME - e.first) < maxPotential));
      }
      print(curTime);
    }
    final currentState = item.second;
    if (item.first < MAX_TIME) {
      final billsToExecute = currentState.bills(blueprint);
      final normalState = currentState.doNothing();
      List<GameState> options = [];
      options.add(normalState);
      for (final bill in billsToExecute) {
        MaterialCounts nextMaterials = normalState.materials - bill.first;
        MaterialCounts nextRobots = normalState.robots + bill.second;
        options.add(GameState(nextMaterials, nextRobots));
      }
      final timeRemaining = MAX_TIME - timeElapsed - 1;
      for (final option in options) {
        final potential = option.potential(timeRemaining);
        final key = option.toString();
        if (potential > maxGeodes && !seen.contains(key)) {
          seen.add(key);
          queue.add(Pair(timeElapsed + 1, option));
        }
      }
    } else if (MAX_TIME == timeElapsed) {
      if (currentState.materials.geode > maxGeodes) {
        maxGeodes = currentState.materials.geode;
      }
    }
  }

  return maxGeodes;
}

int evaluateBlueprint(Blueprint blueprint) {
  // return evaluateState(blueprint, state, 0, {});
  return evaluateState(blueprint,
      GameState(MaterialCounts(0, 0, 0, 0), MaterialCounts(1, 0, 0, 0)));
}

void main() async {
  final input = await parseInput('19/input');
  List<int> totals = [0, 0, 0];
  for (int idx in [0, 1, 2]) {
    final blueprint = input[idx];
    final totalGeodes = evaluateBlueprint(blueprint);
    totals[idx] = totalGeodes;
    print("${idx + 1}/${3} (+$totalGeodes)");
  }
  print(totals[0] * totals[1] * totals[2]);
}
