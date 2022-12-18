import 'package:equatable/equatable.dart';

import '../utils.dart';

class TunnelNode extends Equatable {
  final String name;
  final int flowRate;
  final List<String> connectedTo;

  TunnelNode(this.name, this.flowRate, this.connectedTo);

  @override
  String toString() {
    return "[$name] r=$flowRate, t=$connectedTo";
  }

  @override
  List<Object?> get props => [name];
}

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

typedef Input = List<TunnelNode>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final valveNameRegExp = new RegExp(r"Valve (\w.) has");
  final flowRateRegExp = new RegExp(r"rate=(\d+);");
  final valvesRegExp = new RegExp(r"leads? to valves? (.*)");
  return inputLineList.map((line) {
    final name = valveNameRegExp.firstMatch(line)!.group(1)!;
    final flowRate = int.parse(flowRateRegExp.firstMatch(line)!.group(1)!);
    final leadsTo = valvesRegExp.firstMatch(line)!.group(1)!;
    final connectedTo = leadsTo.split(", ");
    return TunnelNode(name, flowRate, connectedTo);
  }).toList();
}
