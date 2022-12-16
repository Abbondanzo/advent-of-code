import '../utils.dart';

class TunnelNode {
  final String name;
  final int flowRate;
  final List<String> connectedTo;

  TunnelNode(this.name, this.flowRate, this.connectedTo);

  @override
  String toString() {
    return "[$name] r=$flowRate, t=$connectedTo";
  }
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
