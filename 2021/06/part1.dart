import '../utils.dart';

List<int> tickFish(List<int> fish) {
  int numToAdd = 0;
  final existingFish = fish.map((element) {
    if (element == 0) {
      numToAdd++;
      return 6;
    } else {
      return element - 1;
    }
  }).toList(); // Must call toList in order to evaluate and have number below
  return existingFish.followedBy(List.filled(numToAdd, 8)).toList();
}

void main() async {
  final inputLines = readFile('6/input');
  final inputLineList = await inputLines.toList();
  assert(inputLineList.length == 1);

  List<int> fish =
      inputLineList[0].split(',').map((element) => int.parse(element)).toList();

  int day = 0;
  final totalDays = 80;
  while (day < totalDays) {
    day++;
    fish = tickFish(fish);
  }

  print('Number of fish after $totalDays days: ${fish.length}');
}
