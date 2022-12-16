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

typedef TimeRemainingToNode = Pair<int, TunnelNode>;

typedef DistanceToNode = Pair<int, TunnelNode>;

List<DistanceToNode> edges(String start, TunnelMap map,
    DistancesMap distancesMap, Set<String> opened) {
  final unopenedNodes = map.values.where((node) => !opened.contains(node.name));
  final starterNode = map[start]!;
  return unopenedNodes.map((unopenedNode) {
    final distance = distancesMap[starterNode.name]![unopenedNode.name]!;
    return Pair(distance, unopenedNode);
  }).toList();
}

class QueueItem {
  final int totalSoFar;
  final int timeRemaining;
  final int flowPerTurn;
  final Set<String> opened;
  final TunnelNode curNode;

  QueueItem(this.totalSoFar, this.timeRemaining, this.flowPerTurn, this.opened,
      this.curNode);

  QueueItem openCurrentNode() {
    final newSet = Set<String>();
    newSet.addAll(opened);
    newSet.add(curNode.name);
    return QueueItem(totalSoFar + flowPerTurn, timeRemaining - 1,
        flowPerTurn + curNode.flowRate, newSet, curNode);
  }

  QueueItem goToNeighbor(TunnelNode neighborNode) {
    assert(curNode.connectedTo.contains(neighborNode.name));
    return QueueItem(totalSoFar + flowPerTurn, timeRemaining - 1, flowPerTurn,
        opened, curNode);
  }
}

QueueItem removePriority(List<QueueItem> queue) {
  queue.sort((a, b) {
    final flowRateA = a.totalSoFar + a.flowPerTurn * a.timeRemaining;
    final flowRateB = b.totalSoFar + b.flowPerTurn * b.timeRemaining;
    return flowRateA > flowRateB
        ? -1
        : flowRateB > flowRateA
            ? 1
            : 0;
  });
  final removed = queue.removeAt(0);
  return removed;
}

List<String> dijkstras(String first, TunnelMap map, DistancesMap distancesMap) {
  assert(map.length > 0);
  final start = map[first]!;
  List<QueueItem> queue = [QueueItem(0, 30, 0, {}, start)];
  Map<String, int> maxOutput = Map();
  Map<String, String> prev = Map();
  Set<String> opened = Set();
  while (queue.isNotEmpty) {
    final queueItem = removePriority(queue);
    if (queueItem.timeRemaining <= 0) {
      continue;
    }

    // Add open check
    if (!queueItem.opened.contains(queueItem.curNode.name)) {
      queue.add(queueItem.openCurrentNode());
    }

    for (String neighbor in queueItem.curNode.connectedTo) {
      final neighborNode = map[neighbor]!;
      final nextState = queueItem.goToNeighbor(neighborNode);
      queue.add(nextState);
    }

    // for (final edge in edges(node.name, map, distancesMap, opened)) {
    //   final distance = edge.first;
    //   final edgeNode = edge.second;
    //   final newTimeRemaining = timeRemaining - distance - 1;
    //   final additionalOutput = newTimeRemaining * edgeNode.flowRate;
    //   if (additionalOutput > (maxOutput[edgeNode.name] ?? 0)) {
    //     maxOutput[edgeNode.name] = additionalOutput;
    //     prev[edgeNode.name] = node.name;
    //     queue.add(Pair(newTimeRemaining, edgeNode));
    //   }
    // }
  }
  print(prev);
  print(maxOutput);
  return [];
}

void main() async {
  final input = await parseInput('16/demo');

  final map = toMap(input);
  final distances = toDistances(map);

  final path = dijkstras(input[0].name, map, distances);
}
