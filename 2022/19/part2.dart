import './shared.dart';
import '../utils.dart';

final MAX_TIME = 24;

class GameState {
  int oreRobots = 1;
  int clayRobots = 0;
  int obsidianRobots = 0;
  int geodeRobots = 0;

  int ore = 0;
  int clay = 0;
  int obsidian = 0;
  int geodes = 0;

  GameState copy() {
    final newState = GameState();
    newState.oreRobots = oreRobots;
    newState.clayRobots = clayRobots;
    newState.obsidianRobots = obsidianRobots;
    newState.geodeRobots = geodeRobots;
    newState.ore = ore;
    newState.clay = clay;
    newState.obsidian = obsidian;
    newState.geodes = geodes;
    return newState;
  }

  int maxGeodes(int iterations) {
    return geodes + (geodeRobots * iterations);
  }

  @override
  String toString() {
    return "GS($ore+$oreRobots, $clay+$clayRobots, $obsidian+$obsidianRobots, $geodes+$geodeRobots)";
  }

  List<GameState> next(Blueprint blueprint) {
    final options = _purchaseOptions(blueprint);
    final nothingCopy = copy();
    nothingCopy._simulate();
    options.add(nothingCopy);
    return options;
  }

  void _simulate() {
    ore += oreRobots;
    clay += clayRobots;
    obsidian += obsidianRobots;
    geodes += geodeRobots;
  }

  bool shouldSkip(Blueprint blueprint) {
    int maxOre = 0;
    int maxClay = 0;
    int maxObsidian = 0;

    if (blueprint.oreRobot > maxOre) {
      maxOre = blueprint.oreRobot;
    }
    if (blueprint.clayRobot > maxOre) {
      maxOre = blueprint.clayRobot;
    }
    if (blueprint.obsidianRobot.first > maxOre) {
      maxOre = blueprint.obsidianRobot.first;
    }
    if (blueprint.obsidianRobot.second > maxClay) {
      maxClay = blueprint.obsidianRobot.second;
    }
    if (blueprint.geodeRobot.first > maxOre) {
      maxOre = blueprint.geodeRobot.first;
    }
    if (blueprint.geodeRobot.second > maxObsidian) {
      maxObsidian = blueprint.geodeRobot.second;
    }

    return ore > maxOre && clay > maxClay && obsidian > maxObsidian;
  }

  List<GameState> _purchaseOptions(Blueprint blueprint) {
    List<GameState> options = [];
    if (ore >= blueprint.oreRobot) {
      final newState = copy();
      newState.ore -= blueprint.oreRobot;
      newState._simulate();
      newState.oreRobots++;
      options.add(newState);
    }
    if (ore >= blueprint.clayRobot) {
      final newState = copy();
      newState.ore -= blueprint.clayRobot;
      newState._simulate();
      newState.clayRobots++;
      options.add(newState);
    }
    if (ore >= blueprint.obsidianRobot.first &&
        clay >= blueprint.obsidianRobot.second) {
      final newState = copy();
      newState.ore -= blueprint.obsidianRobot.first;
      newState.clay -= blueprint.obsidianRobot.second;
      newState._simulate();
      newState.obsidianRobots++;
      options.add(newState);
    }
    if (ore >= blueprint.geodeRobot.first &&
        obsidian >= blueprint.geodeRobot.second) {
      final newState = copy();
      newState.ore -= blueprint.geodeRobot.first;
      newState.obsidian -= blueprint.geodeRobot.second;
      newState._simulate();
      newState.geodeRobots++;
      options.add(newState);
    }
    return options;
  }
}

// time elapsed, state
typedef QueueItem = Pair<int, GameState>;

QueueItem sortAndRemoveFirst(List<QueueItem> queue, int minGeodes) {
  queue.removeWhere((element) =>
      element.second.maxGeodes(MAX_TIME - element.first) < minGeodes);
  queue.sort((a, b) => b.second
      .maxGeodes(MAX_TIME - b.first)
      .compareTo(a.second.maxGeodes(MAX_TIME - a.first)));
  final toRemove = queue.removeAt(0);
  return toRemove;
}

int evaluateStateBFS(Blueprint blueprint, GameState state) {
  final List<Pair<int, GameState>> queue = [Pair(0, state)];
  final Set<String> seen = {};
  final Map<String, bool> skip = {};
  int maxGeodes = 0;
  int iterations = 0;
  while (queue.isNotEmpty) {
    final item = sortAndRemoveFirst(queue, maxGeodes);

    if (item.first == MAX_TIME) {
      if (item.second.geodes > maxGeodes) {
        maxGeodes = item.second.geodes;
        print(maxGeodes);
      }
      continue;
    }

    final options = item.second.next(blueprint);
    for (final nextState in options) {
      final key = nextState.toString();
      if (!skip.containsKey(key)) {
        skip[key] = nextState.shouldSkip(blueprint);
      }
      if (skip[key]!) continue;
      final nextTime = item.first + 1;
      if (!seen.contains(key)) {
        seen.add(key);
        queue.add(Pair(nextTime, nextState));
      }
    }
    iterations++;
    if (iterations > 1000000) {
      throw Error();
    }
  }

  return maxGeodes;
}

void main() async {
  final input = await parseInput('19/input');
  int total = 0;
  for (int idx in [1]) {
    final blueprint = input[idx];
    final totalGeodes = evaluateStateBFS(blueprint, GameState());
    total += totalGeodes * (idx + 1);
    print("${idx + 1}/${input.length} (+$totalGeodes)");
  }
  print(total);
}
