import 'dart:math';

import './shared.dart';
import '../utils.dart';

int MAX_TIME = 24;

// GameState sortAndRemoveFirst(List<GameState> queue, int maxGeodes) {
//   queue.sort((a, b) => b.maxGeodes().compareTo(a.maxGeodes()));
//   while (queue.length > 1000) {
//     queue.removeLast();
//   }
//   return queue.removeAt(0);
// }

int potential(
    int timeRemaining, MaterialCounts materials, MaterialCounts robots) {
  final tries = (timeRemaining * (timeRemaining - 1)) ~/ 2;
  return materials.geode + (robots.geode * timeRemaining) + tries;
}

List<Pair<MaterialCounts, MaterialCounts>> bills(
    Blueprint blueprint, MaterialCounts materials, MaterialCounts robots) {
  List<Pair<MaterialCounts, MaterialCounts>> options = [];
  for (final bill in blueprint.bills) {
    final costs = bill.first;
    final canAfford = range(materials.list.length)
        .every((index) => materials.list[index] >= costs.list[index]);
    if (!canAfford) continue;
    options.add(bill);
  }
  return options.reversed.toList();
}

MaterialCounts update(MaterialCounts materials, MaterialCounts robots) {
  return materials + robots;
}

int evaluateState(
    Blueprint blueprint,
    int timeRemaining,
    MaterialCounts materials,
    MaterialCounts robots,
    int maxGeodes,
    Set<String> seen) {
  final key = "$timeRemaining $materials $robots";
  if (seen.contains(key)) return maxGeodes;
  seen.add(key);
  if (potential(timeRemaining, materials, robots) <= maxGeodes) {
    return maxGeodes;
  }
  final billsToExecute = bills(blueprint, materials, robots);
  materials = update(materials, robots);
  if (timeRemaining == 1) {
    return materials.geode;
  }
  final nextState = evaluateState(
      blueprint, timeRemaining - 1, materials, robots, maxGeodes, seen);
  if (nextState > maxGeodes) {
    maxGeodes = nextState;
  }
  for (final bill in billsToExecute) {
    MaterialCounts nextMaterials = materials - bill.first;
    MaterialCounts nextRobots = robots + bill.second;
    final nextGeodes = evaluateState(blueprint, timeRemaining - 1,
        nextMaterials, nextRobots, maxGeodes, seen);
    if (nextGeodes > maxGeodes) {
      maxGeodes = nextGeodes;
    }
  }
  return maxGeodes;
}

int evaluateBlueprint(Blueprint blueprint) {
  // return evaluateState(blueprint, state, 0, {});
  return evaluateState(blueprint, MAX_TIME, MaterialCounts(0, 0, 0, 0),
      MaterialCounts(1, 0, 0, 0), 0, {});
}

void main() async {
  final input = await parseInput('19/input');
  int total = 0;
  // for (int idx in [1]) {
  for (int idx in range(input.length)) {
    final blueprint = input[idx];
    final totalGeodes = evaluateBlueprint(blueprint);
    total += totalGeodes * (idx + 1);
    print("${idx + 1}/${input.length} (+$totalGeodes)");
  }
  print(total);
}
