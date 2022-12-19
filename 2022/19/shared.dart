import '../utils.dart';

class Blueprint {
  // ore
  final int oreRobot;
  // ore
  final int clayRobot;
  // ore/clay
  final Pair<int, int> obsidianRobot;
  // ore/obsidian
  final Pair<int, int> geodeRobot;

  Blueprint(this.oreRobot, this.clayRobot, this.obsidianRobot, this.geodeRobot);

  @override
  String toString() {
    return "Blueprint($oreRobot, $clayRobot, $obsidianRobot, $geodeRobot)";
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
    final oreRobotRaw = parseInts(oreRobotRegExp, line);
    assert(oreRobotRaw.length == 1);
    final clayRobotRaw = parseInts(clayRobotRegExp, line);
    assert(clayRobotRaw.length == 1);
    final obsidianRobotRaw = parseInts(obsidianRobotRegExp, line);
    assert(obsidianRobotRaw.length == 2);
    final geodeRobotRaw = parseInts(geodeRobotRegExp, line);
    assert(geodeRobotRaw.length == 2);
    return Blueprint(
        oreRobotRaw[0],
        clayRobotRaw[0],
        Pair(obsidianRobotRaw[0], obsidianRobotRaw[1]),
        Pair(geodeRobotRaw[0], geodeRobotRaw[1]));
  }).toList();
}
