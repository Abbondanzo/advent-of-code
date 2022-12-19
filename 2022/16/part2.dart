import './shared.dart';
import '../utils.dart';

class GameState {
  final Set<String> opened;
  final int totalFlow;
  final int flowRate;
  final int timeElapsed;

  GameState(
    this.opened,
    this.totalFlow,
    this.flowRate,
    this.timeElapsed,
  );

  List<TunnelNode> unvisited(TunnelMap map) {
    return map.values.where((node) => !opened.contains(node.name)).toList();
  }

  GameState next(String nextName, int nextFlow, int time) {
    final Set<String> newOpened = Set();
    newOpened.addAll(opened);
    newOpened.add(nextName);
    final newTotalFlow = totalFlow + (time * flowRate);
    final newFlowRate = flowRate + nextFlow;
    final newTimeElapsed = timeElapsed + time;
    return GameState(newOpened, newTotalFlow, newFlowRate, newTimeElapsed);
  }

  GameState flowTo(int time) {
    final newTotalFlow = totalFlow + (time - timeElapsed) * flowRate;
    return GameState(opened, newTotalFlow, flowRate, time);
  }

  @override
  String toString() {
    return "t=$totalFlow : r=$flowRate : s=$timeElapsed, o=$opened";
  }
}

int flowTotal(int timeLimit, DistancesMap distances, TunnelMap valves) {
  List<Map<String, GameState>> states =
      List.generate(timeLimit + 1, (_) => Map());
  final starterState = GameState({}, 0, 0, 0);
  for (TunnelNode nextNode in starterState.unvisited(valves)) {
    final distance = distances["AA"]![nextNode.name]!;
    final nextState =
        starterState.next(nextNode.name, nextNode.flowRate, distance + 1);
    states[nextState.timeElapsed][nextNode.name] = nextState;
  }

  for (int time in range(timeLimit + 1)) {
    for (String valve in valves.keys) {
      final maybeState = states[time][valve];
      if (maybeState != null) {
        // If we stay here
        for (int remainderTime in range(time + 1, timeLimit + 1)) {
          final nextState = maybeState.flowTo(remainderTime);
          final existingNextState = states[remainderTime][valve];
          if (existingNextState == null ||
              existingNextState.totalFlow < nextState.totalFlow) {
            states[nextState.timeElapsed][valve] = nextState;
          }
        }
        // If we move
        for (TunnelNode nextNode in maybeState.unvisited(valves)) {
          final distance = distances[valve]![nextNode.name]!;
          final nextState =
              maybeState.next(nextNode.name, nextNode.flowRate, distance + 1);
          if (nextState.timeElapsed > timeLimit) {
            continue;
          }
          final existingNextState =
              states[nextState.timeElapsed][nextNode.name];
          if (existingNextState == null ||
              existingNextState.totalFlow < nextState.totalFlow) {
            states[nextState.timeElapsed][nextNode.name] = nextState;
          }
        }
      }
    }
  }

  final finalValues = states[timeLimit].values.toList();
  finalValues.sort((a, b) => a.totalFlow > b.totalFlow
      ? -1
      : b.totalFlow > a.totalFlow
          ? 1
          : 0);

  return finalValues.first.totalFlow;
}

void main() async {
  final input = await parseInput('16/input');
  final map = toMap(input);
  final distances = toDistances(map);
  final filteredMap = filterMap(map);

  void filler(List<List<int>> combinations, List<int> data, int start, int end,
      int index) {
    if (index == data.length) {
      combinations.add(data.sublist(0));
    } else if (start <= end) {
      data[index] = start;
      filler(combinations, data, start + 1, end, index + 1);
      filler(combinations, data, start + 1, end, index);
    }
  }

  final List<List<int>> combinations = [];
  final halfSize = (filteredMap.length / 2).ceil();
  filler(combinations, List.filled(halfSize, 0), 0, filteredMap.keys.length - 1,
      0);

  final pairings = combinations.map((indices) {
    final Map<String, TunnelNode> first = {};
    final Map<String, TunnelNode> second = {};
    final entries = filteredMap.entries.toList();
    for (int idx in range(entries.length)) {
      final entry = entries[idx];
      if (indices.contains(idx)) {
        first[entry.key] = entry.value;
      } else {
        second[entry.key] = entry.value;
      }
    }
    return Pair(first, second);
  }).toList();

  int max = 0;
  pairings.forEach((pairing) {
    final time = 26;
    final total = flowTotal(time, distances, pairing.first) +
        flowTotal(time, distances, pairing.second);
    if (total > max) {
      max = total;
    }
  });

  print(max);
}
