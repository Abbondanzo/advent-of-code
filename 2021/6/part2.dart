import '../utils.dart';

Future<Map<int, int>> parseInput() async {
  final inputLines = readFile('6/input');
  final inputLineList = await inputLines.toList();
  assert(inputLineList.length == 1);
  final fishAgeMap = Map<int, int>();
  inputLineList[0].split(',').forEach((element) {
    final age = int.parse(element);
    fishAgeMap.update(
      age,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  });
  return fishAgeMap;
}

Map<int, int> tickFish(Map<int, int> fishAgeMap) {
  final newFishAgeMap = Map<int, int>();
  // Create new fish
  newFishAgeMap[8] = fishAgeMap[0] ?? 0;
  // Age remaining fish
  fishAgeMap.forEach((age, count) {
    final nextAge = age == 0 ? 6 : age - 1;
    newFishAgeMap.update(nextAge, (value) => value + count,
        ifAbsent: () => count);
  });
  return newFishAgeMap;
}

void main() async {
  Map<int, int> fishAgeMap = await parseInput();
  int day = 0;
  final totalDays = 256;
  while (day < totalDays) {
    day++;
    fishAgeMap = tickFish(fishAgeMap);
  }
  final fishCount =
      fishAgeMap.values.reduce((value, element) => value + element);
  print('Number of fish after $totalDays days: $fishCount');
}
