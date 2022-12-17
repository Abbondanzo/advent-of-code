import 'dart:math';

import './shared.dart';
import '../utils.dart';

typedef TunnelMap = Map<String, TunnelNode>;

TunnelMap toMap(Input input) {
  return input.fold<TunnelMap>(Map(), (previousValue, element) {
    previousValue[element.name] = element;
    return previousValue;
  });
}

typedef DistancesMap = Map<String, Map<String, int>>;

DistancesMap toDistances(TunnelMap map) {
  final distances = DistancesMap();
  map.entries.forEach((element) {
    final starterNode = element.value;
    final nodeDistances = Map<String, int>();
    final queue = [starterNode.connectedTo];
    int distance = 1;
    while (queue.isNotEmpty) {
      final List<String> nextQueue = [];
      for (String neighbor in queue.removeAt(0)) {
        nodeDistances[neighbor] = distance;
        final neighborNode = map[neighbor]!;
        neighborNode.connectedTo.forEach((element) {
          if (starterNode.name != element &&
              !nodeDistances.keys.contains(element)) {
            nextQueue.add(element);
          }
        });
      }
      if (nextQueue.isEmpty) {
        break;
      }
      queue.add(nextQueue);
      distance++;
    }
    distances[element.key] = nodeDistances;
  });
  return distances;
}

TunnelMap filterMap(TunnelMap map) {
  final TunnelMap newMap = Map();
  newMap.addEntries(map.entries.where((element) => element.value.flowRate > 0));
  return newMap;
}

// typedef TimeRemainingToNode = Pair<int, TunnelNode>;

// class QueueItem {
//   final int totalSoFar;
//   final int timeRemaining;
//   final int flowPerTurn;
//   final Set<String> opened;
//   final TunnelNode curNode;

//   QueueItem(this.totalSoFar, this.timeRemaining, this.flowPerTurn, this.opened,
//       this.curNode);

//   QueueItem openCurrentNode() {
//     final newSet = Set<String>();
//     newSet.addAll(opened);
//     newSet.add(curNode.name);
//     return QueueItem(totalSoFar + flowPerTurn, timeRemaining - 1,
//         flowPerTurn + curNode.flowRate, newSet, curNode);
//   }

//   QueueItem goToNeighbor(TunnelNode neighborNode) {
//     assert(curNode.connectedTo.contains(neighborNode.name));
//     return QueueItem(totalSoFar + flowPerTurn, timeRemaining - 1, flowPerTurn,
//         opened, curNode);
//   }

//   QueueItem goToOtherNode(int distance, TunnelNode otherNode) {
//     assert(otherNode != curNode);
//     return QueueItem(totalSoFar + (flowPerTurn * distance),
//         timeRemaining - distance, flowPerTurn, opened, otherNode);
//   }

//   @override
//   String toString() {
//     // TODO: implement toString
//     return "$totalSoFar $timeRemaining";
//   }
// }

// QueueItem removePriority(List<QueueItem> queue) {
//   queue.sort((a, b) {
//     final flowRateA = a.totalSoFar + a.flowPerTurn * a.timeRemaining;
//     final flowRateB = b.totalSoFar + b.flowPerTurn * b.timeRemaining;
//     return flowRateA > flowRateB
//         ? -1
//         : flowRateB > flowRateA
//             ? 1
//             : 0;
//   });
//   final removed = queue.removeAt(0);
//   return removed;
// }

// typedef DistanceToNode = Pair<int, TunnelNode>;

// List<QueueItem> edges(
//     QueueItem queueItem, TunnelMap map, DistancesMap distancesMap) {
//   final unopenedNodes = map.values.where((node) =>
//       !queueItem.opened.contains(node.name) &&
//       node.name != queueItem.curNode.name);
//   final starterNode = map[queueItem.curNode.name]!;
//   return unopenedNodes.map((unopenedNode) {
//     final distance = distancesMap[starterNode.name]![unopenedNode.name]!;
//     return queueItem.goToOtherNode(distance, unopenedNode);
//   }).toList();
// }

// List<String> dijkstras(String first, TunnelMap map, DistancesMap distancesMap) {
//   assert(map.length > 0);
//   final start = map[first]!;
//   List<QueueItem> queue = [QueueItem(0, 30, 0, {}, start)];
//   Map<String, int> maxOutput = Map();
//   Map<String, String> prev = Map();
//   while (queue.isNotEmpty) {
//     final queueItem = removePriority(queue);
//     if (queueItem.timeRemaining <= 2) {
//       continue;
//     }
//     print(queueItem);

//     // Add open check
//     if (!queueItem.opened.contains(queueItem.curNode.name)) {
//       queue.add(queueItem.openCurrentNode());
//     }

//     // for (String neighbor in queueItem.curNode.connectedTo) {
//     //   final neighborNode = map[neighbor]!;
//     //   final nextState = queueItem.goToNeighbor(neighborNode);
//     //   queue.add(nextState);
//     // }

//     for (final edge in edges(queueItem, map, distancesMap)) {
//       final nextEdge = queue.add(edge.openCurrentNode());
//     }

//     // for (final edge in edges(node.name, map, distancesMap, opened)) {
//     //   final distance = edge.first;
//     //   final edgeNode = edge.second;
//     //   final newTimeRemaining = timeRemaining - distance - 1;
//     //   final additionalOutput = newTimeRemaining * edgeNode.flowRate;
//     //   if (additionalOutput > (maxOutput[edgeNode.name] ?? 0)) {
//     //     maxOutput[edgeNode.name] = additionalOutput;
//     //     prev[edgeNode.name] = node.name;
//     //     queue.add(Pair(newTimeRemaining, edgeNode));
//     //   }
//     // }
//   }
//   print(prev);
//   print(maxOutput);
//   return [];
// }

class GameState {
  final Set<String> opened;
  final int totalFlow;
  final int flowRate;
  final int timeElapsed;
  final TunnelNode curNode;

  GameState(this.opened, this.totalFlow, this.flowRate, this.timeElapsed,
      this.curNode);

  List<TunnelNode> unvisited(TunnelMap map) {
    return map.values.where((node) => !opened.contains(node.name)).toList();
  }

  GameState next(TunnelNode nextNode, int distance) {
    final Set<String> newOpened = Set();
    newOpened.addAll(opened);
    newOpened.add(nextNode.name);
    final timeToOpen = distance + 1;
    final newTotalFlow = totalFlow + (timeToOpen * flowRate);
    final newFlowRate = flowRate + nextNode.flowRate;
    final newTimeElapsed = timeElapsed + timeToOpen;
    return GameState(
        newOpened, newTotalFlow, newFlowRate, newTimeElapsed, nextNode);
  }

  GameState flowTo(int time) {
    final newTotalFlow = totalFlow + (time - timeElapsed) * flowRate;
    return GameState(opened, newTotalFlow, flowRate, time, curNode);
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

  print({"AA", "BB"}.difference({"BB", "AA"}));

  int maxTotal = 0;
  GameState? max;
  List<GameState> states = [GameState({}, 0, 0, 0, input.first)];
  while (states.isNotEmpty) {
    final curState = states.removeAt(0);
    if (curState.totalFlow > 1600) {
      print(curState);
    }
    final nextNodes = curState.unvisited(filteredMap);
    for (TunnelNode nextNode in nextNodes) {
      final distance = distances[curState.curNode.name]![nextNode.name]!;
      final nextState = curState.next(nextNode, distance);
      if (nextState.timeElapsed <= 30) {
        if (nextState.totalFlow > maxTotal) {
          maxTotal = nextState.totalFlow;
          max = nextState;
        }
        if (nextState.timeElapsed < 30) {
          states.add(nextState);
        }
      }
    }
    // Also check what happens until time elapsed
    if (curState.timeElapsed < 30) {
      final toEnd = curState.flowTo(30);
      if (toEnd.totalFlow > maxTotal) {
        maxTotal = toEnd.totalFlow;
        max = toEnd;
      }
    }
  }
  print(max);
}
