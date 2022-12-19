import './shared.dart';
import '../utils.dart';

int MAX_TIME = 24;

class GameState {
  int _oreRobots = 1;
  int _clayRobots = 0;
  int _obsidianRobots = 0;
  int _geodeRobots = 0;

  int _ore = 0;
  int _clay = 0;
  int _obsidian = 0;
  int _geodes = 0;

  final Blueprint _blueprint;

  GameState(this._blueprint);

  void simulate() {
    _ore += _oreRobots;
    _clay += _clayRobots;
    _obsidian += _obsidianRobots;
    _geodes += _geodeRobots;
  }

  GameState copy() {
    final newState = GameState(_blueprint);
    newState._ore = _ore;
    newState._clay = _clay;
    newState._obsidian = _obsidian;
    newState._geodes = _geodes;
    newState._oreRobots = _oreRobots;
    newState._clayRobots = _clayRobots;
    newState._obsidianRobots = _obsidianRobots;
    newState._geodeRobots = _geodeRobots;
    return newState;
  }

  bool shouldSkip() {
    return (_ore > _blueprint.oreRobot) &&
        (_ore > _blueprint.clayRobot) &&
        (_ore > _blueprint.obsidianRobot.first &&
            (_clay > _blueprint.obsidianRobot.second || _clayRobots == 0)) &&
        (_ore > _blueprint.geodeRobot.first &&
            (_obsidian > _blueprint.geodeRobot.second || _obsidianRobots == 0));
  }

  List<GameState> buildOptions() {
    List<GameState> options = [];
    if (_ore >= _blueprint.oreRobot) {
      final newState = copy();
      newState._ore -= _blueprint.oreRobot;
      newState.simulate();
      newState._oreRobots++;
      options.add(newState);
    }
    if (_ore >= _blueprint.clayRobot) {
      final newState = copy();
      newState._ore -= _blueprint.clayRobot;
      newState.simulate();
      newState._clayRobots++;
      options.add(newState);
    }
    if (_ore >= _blueprint.obsidianRobot.first &&
        _clay >= _blueprint.obsidianRobot.second) {
      final newState = copy();
      newState._ore -= _blueprint.obsidianRobot.first;
      newState._clay -= _blueprint.obsidianRobot.second;
      newState.simulate();
      newState._obsidianRobots++;
      options.add(newState);
    }
    if (_ore >= _blueprint.geodeRobot.first &&
        _obsidian >= _blueprint.geodeRobot.second) {
      final newState = copy();
      newState._ore -= _blueprint.geodeRobot.first;
      newState._obsidian -= _blueprint.geodeRobot.second;
      newState.simulate();
      newState._geodeRobots++;
      options.add(newState);
    }
    return options;
  }

  @override
  String toString() {
    return "GS($_ore+$_oreRobots, $_clay+$_clayRobots, $_obsidian+$_obsidianRobots, $_geodes+$_geodeRobots)";
  }
}

int evaluateState(int timeElapsed, GameState state, Map<String, int> seen) {
  final stateKey = state.toString();
  // if (timeElapsed == MAX_TIME) {
  //   print(stateKey);
  // }
  if (seen.containsKey(stateKey)) return seen[stateKey]!;
  if (timeElapsed >= MAX_TIME) return state._geodes;
  final options = state.buildOptions();
  final newState = state.copy();
  newState.simulate();
  int maxGeodes = newState.shouldSkip()
      ? 0
      : evaluateState(timeElapsed + 1, newState, seen);
  for (final nextState in options) {
    final totalGeodes = evaluateState(timeElapsed + 1, nextState, seen);
    if (totalGeodes > maxGeodes) {
      maxGeodes = totalGeodes;
    }
  }
  seen[stateKey] = maxGeodes;
  return maxGeodes;
}

int evaluateBlueprint(Blueprint blueprint) {
  GameState state = GameState(blueprint);
  return evaluateState(0, state, {});
}

void main() async {
  final input = await parseInput('19/input');
  int total = 0;
  for (int idx in range(input.length)) {
    final blueprint = input[idx];
    final totalGeodes = evaluateBlueprint(blueprint);
    total += totalGeodes * (idx + 1);
    print("${idx + 1}/${input.length} (+$totalGeodes)");
  }
  // TODO: >1640
  print(total);
}
