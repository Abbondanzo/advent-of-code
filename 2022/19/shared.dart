import 'package:equatable/equatable.dart';

import '../utils.dart';

class MaterialCounts extends Equatable {
  final int ore;
  final int clay;
  final int obsidian;
  final int geode;

  late final List<int> list = [ore, clay, obsidian, geode];

  MaterialCounts(this.ore, this.clay, this.obsidian, this.geode);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [ore, clay, obsidian, geode];

  operator +(MaterialCounts other) {
    return MaterialCounts(ore + other.ore, clay + other.clay,
        obsidian + other.obsidian, geode + other.geode);
  }

  operator -(MaterialCounts other) {
    return MaterialCounts(ore - other.ore, clay - other.clay,
        obsidian - other.obsidian, geode - other.geode);
  }

  operator *(int multiplier) {
    return MaterialCounts(ore * multiplier, clay * multiplier,
        obsidian * multiplier, geode * multiplier);
  }
}

typedef CostToOutput = Pair<MaterialCounts, MaterialCounts>;

class Blueprint {
  // <costs, output>[]
  final List<CostToOutput> bills;
  final MaterialCounts maxCosts;

  Blueprint(this.bills) : maxCosts = _maxCosts(bills);

  @override
  String toString() {
    return "Blueprint($bills)";
  }

  static MaterialCounts _maxCosts(List<CostToOutput> bills) {
    int maxOre = 0;
    int maxClay = 0;
    int maxObsidian = 0;
    int maxGeodes = 0; // Not that it'll be non-zero

    for (final bill in bills) {
      if (bill.first.ore > maxOre) maxOre = bill.first.ore;
      if (bill.first.clay > maxClay) maxClay = bill.first.clay;
      if (bill.first.obsidian > maxObsidian) maxObsidian = bill.first.obsidian;
      if (bill.first.geode > maxGeodes) maxGeodes = bill.first.geode;
    }

    return MaterialCounts(maxOre, maxClay, maxObsidian, maxGeodes);
  }
}

typedef Input = List<Blueprint>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final oreRobotRegExp = new RegExp(r"Each ore robot costs (\d+) ore");
  final clayRobotRegExp = new RegExp(r"Each clay robot costs (\d+) ore");
  final obsidianRobotRegExp =
      new RegExp(r"Each obsidian robot costs (\d+) ore and (\d+) clay");
  final geodeRobotRegExp =
      new RegExp(r"Each geode robot costs (\d+) ore and (\d+) obsidian");
  List<int> parseInts(RegExp expr, String line) {
    final match = expr.firstMatch(line)!;
    List<int> ints = [];
    for (int group in range(1, match.groupCount + 1)) {
      ints.add(int.parse(match.group(group)!));
    }
    return ints;
  }

  return inputLineList.map((line) {
    final List<CostToOutput> costs = [];

    final oreRobotRaw = parseInts(oreRobotRegExp, line);
    assert(oreRobotRaw.length == 1);
    costs.add(Pair(
        MaterialCounts(oreRobotRaw[0], 0, 0, 0), MaterialCounts(1, 0, 0, 0)));

    final clayRobotRaw = parseInts(clayRobotRegExp, line);
    assert(clayRobotRaw.length == 1);
    costs.add(Pair(
        MaterialCounts(clayRobotRaw[0], 0, 0, 0), MaterialCounts(0, 1, 0, 0)));

    final obsidianRobotRaw = parseInts(obsidianRobotRegExp, line);
    assert(obsidianRobotRaw.length == 2);
    costs.add(Pair(
        MaterialCounts(obsidianRobotRaw[0], obsidianRobotRaw[1], 0, 0),
        MaterialCounts(0, 0, 1, 0)));

    final geodeRobotRaw = parseInts(geodeRobotRegExp, line);
    assert(geodeRobotRaw.length == 2);
    costs.add(Pair(MaterialCounts(geodeRobotRaw[0], 0, geodeRobotRaw[1], 0),
        MaterialCounts(0, 0, 0, 1)));

    return Blueprint(costs);
  }).toList();
}
