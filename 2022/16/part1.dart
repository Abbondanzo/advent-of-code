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

  GameState next(String nextName, int nextFlow, int distance) {
    final Set<String> newOpened = Set();
    newOpened.addAll(opened);
    newOpened.add(nextName);
    final timeToOpen = distance + 1;
    final newTotalFlow = totalFlow + (timeToOpen * flowRate);
    final newFlowRate = flowRate + nextFlow;
    final newTimeElapsed = timeElapsed + timeToOpen;
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

void main() async {
  final input = await parseInput('16/input');
  final map = toMap(input);
  final distances = toDistances(map);
  final filteredMap = filterMap(map);

  List<Map<String, GameState>> states = List.generate(31, (_) => Map());
  final starterState = GameState({}, 0, 0, 0);
  for (TunnelNode nextNode in GameState({}, 0, 0, 0).unvisited(filteredMap)) {
    final distance = distances["AA"]![nextNode.name]!;
    final nextState =
        starterState.next(nextNode.name, nextNode.flowRate, distance);
    states[nextState.timeElapsed][nextNode.name] = nextState;
  }

  for (int time in range(31)) {
    for (String valve in filteredMap.keys) {
      final maybeState = states[time][valve];
      if (maybeState != null) {
        // If we stay here
        for (int remainderTime in range(time + 1, 31)) {
          final nextState = maybeState.flowTo(remainderTime);
          final existingNextState = states[remainderTime][valve];
          if (existingNextState == null ||
              existingNextState.totalFlow < nextState.totalFlow) {
            states[nextState.timeElapsed][valve] = nextState;
          }
        }
        // If we move
        for (TunnelNode nextNode in maybeState.unvisited(filteredMap)) {
          final distance = distances[valve]![nextNode.name]!;
          final nextState =
              maybeState.next(nextNode.name, nextNode.flowRate, distance);
          if (nextState.timeElapsed > 30) {
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

  final finalValues = states[30].values.toList();
  finalValues.sort((a, b) => a.totalFlow > b.totalFlow
      ? -1
      : b.totalFlow > a.totalFlow
          ? 1
          : 0);
  print(finalValues.first.totalFlow);
}