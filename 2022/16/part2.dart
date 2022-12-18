import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import './shared.dart';
import '../utils.dart';
import 'part1.dart';

class WorkLeft {
  final TunnelNode node;
  final int workRemaining;

  WorkLeft(this.node, this.workRemaining);

  @override
  String toString() {
    return "WorkLeft(${node.name}, t=$workRemaining)";
  }
}

class WorkerSpots extends Equatable {
  final List<String> spots;

  WorkerSpots(this.spots);

  @override
  List<Object?> get props => spots;

  @override
  String toString() {
    return "$spots";
  }
}

class GameState {
  final Set<String> opened;
  final int totalFlow;
  final int flowRate;
  final int timeElapsed;
  final List<WorkLeft?> workers;

  GameState(
    this.opened,
    this.totalFlow,
    this.flowRate,
    this.timeElapsed,
    this.workers,
  );

  List<TunnelNode> unvisited(TunnelMap map) {
    return map.values
        .where((node) =>
            !opened.contains(node.name) &&
            workers.every((worker) => worker?.node.name != node.name))
        .toList();
  }

  GameState addWork(int worker, TunnelNode node, int work) {
    assert(workers[worker] == null);
    final newWorkers = workers.sublist(0);
    newWorkers[worker] = WorkLeft(node, work);
    return GameState(opened, totalFlow, flowRate, timeElapsed, newWorkers);
  }

  GameState flowTo(int newTimeElapsed) {
    assert(newTimeElapsed >= timeElapsed);
    final Set<String> newOpened = opened.union({});
    final List<WorkLeft?> newWorkers = workers.sublist(0);
    int newTotalFlow = totalFlow;
    int newFlowRate = flowRate;
    for (int _ in range(timeElapsed, newTimeElapsed + 1)) {
      // First, flow
      newTotalFlow += newFlowRate;
      // Next, open
      for (int i in range(newWorkers.length)) {
        final worker = newWorkers[i];
        if (worker?.workRemaining == 1) {
          newFlowRate += worker!.node.flowRate;
          newOpened.add(worker.node.name);
          newWorkers[i] = null;
        } else if (worker != null) {
          newWorkers[i] = WorkLeft(worker.node, worker.workRemaining - 1);
        }
      }
    }
    return GameState(
        newOpened, newTotalFlow, newFlowRate, newTimeElapsed, newWorkers);
  }

  @override
  String toString() {
    return "t=$totalFlow : r=$flowRate : s=$timeElapsed, o=$opened, w=$workers";
  }
}

void main() async {
  final input = await parseInput('16/demo');
  final map = toMap(input);
  final distances = toDistances(map);
  final filteredMap = filterMap(map);

  final TIME = 26;

  List<Map<WorkerSpots, GameState>> states =
      List.generate(TIME + 1, (_) => Map());
  final starterState = GameState({}, 0, 0, 0, [null, null]);
  states[0][WorkerSpots(["AA", "AA"])] = starterState;

  for (int time in range(TIME + 1)) {
    final Iterable<String> valveKeys;
    if (time == 0) {
      valveKeys = ["AA"];
    } else {
      valveKeys = filteredMap.keys;
    }
    for (String humanValve in valveKeys) {
      for (String elephantValue in valveKeys) {
        final mapKey = WorkerSpots([humanValve, elephantValue]);
        final maybeState = states[time][mapKey];
        if (maybeState == null) {
          print("$time $mapKey ${states[time].keys}");
        }
        if (maybeState != null) {
          print(mapKey);
          // If we stay here
          for (int remainderTime in range(time + 1, TIME + 1)) {
            final nextState = maybeState.flowTo(remainderTime);
            final existingNextState = states[remainderTime][mapKey];
            if (existingNextState == null ||
                existingNextState.totalFlow < nextState.totalFlow) {
              states[nextState.timeElapsed][mapKey] = nextState;
            }
          }
          // If we move
          for (int workerIndex in range(maybeState.workers.length)) {
            // Can't move
            if (maybeState.workers[workerIndex] != null) {
              continue;
            }
            final workerValve = mapKey.spots[workerIndex];
            for (final nextNode in maybeState.unvisited(filteredMap)) {
              final distance = distances[workerValve]![nextNode.name]!;
              final pendingState =
                  maybeState.addWork(workerIndex, nextNode, distance + 1);
              final newSpots = mapKey.spots.sublist(0);
              newSpots[workerIndex] = nextNode.name;
              final newKey = WorkerSpots(newSpots);
              for (int remainderTime in range(time + 1, TIME + 1)) {
                final nextState = pendingState.flowTo(remainderTime);
                final existingNextState = states[remainderTime][newKey];
                if (existingNextState == null ||
                    existingNextState.totalFlow < nextState.totalFlow) {
                  states[nextState.timeElapsed][newKey] = nextState;
                }
              }
            }
          }
        }
      }
    }
  }

  // for (final entry in states) {
  //   print(entry);
  // }

  // for (final entry in states[TIME].entries) {
  //   print(entry);
  // }

  // final finalValues = states[TIME].values.toList();
  // print(finalValues);

  // for (TunnelNode nextNode in starterState.unvisited(filteredMap)) {
  //   final distance = distances["AA"]![nextNode.name]!;
  //   final nextState =
  //       starterState.next(nextNode.name, nextNode.flowRate, distance);
  //   states[nextState.timeElapsed][nextNode.name] = nextState;
  // }
}
