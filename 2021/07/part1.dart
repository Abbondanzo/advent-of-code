import '../utils.dart';

Future<List<int>> parseInput() async {
  // return [16, 1, 2, 0, 4, 2, 7, 1, 2, 14];
  final inputLines = readFile('7/input');
  final inputLineList = await inputLines.toList();
  return inputLineList[0]
      .split(',')
      .map((element) => int.parse(element))
      .toList();
}

int getFuelCost(List<int> input, int position) {
  return input.fold(0, (accValue, element) {
    final distance = (element - position).abs();
    return distance + accValue;
  });
}

void bruteForce(List<int> input) {
  final maxPosition = input[input.length - 1];
  int? cheapestUsage = null;
  int cheapestPosition = 0;
  for (int position = 0; position <= maxPosition; position++) {
    final fuelUsage = getFuelCost(input, position);
    if (cheapestUsage == null || fuelUsage < cheapestUsage) {
      cheapestUsage = fuelUsage;
      cheapestPosition = position;
    }
  }

  // How much fuel must they spend to align to that position?
  print('Crabs spend $cheapestUsage fuel to reach position $cheapestPosition');
}

void fast(List<int> input) {
  final position = median(input);
  final cheapestUsage = getFuelCost(input, position);
  // How much fuel must they spend to align to that position?
  print('Crabs spend $cheapestUsage fuel to reach position $position');
}

void main() async {
  final crabPositions = await parseInput();
  crabPositions.sort((a, b) => a.compareTo(b));

  Stopwatch stopwatch = new Stopwatch()..start();
  bruteForce(crabPositions);
  print('Brute force ${stopwatch.elapsedMicroseconds} us');

  print('');
  stopwatch.stop();
  stopwatch.reset();

  stopwatch.start();
  fast(crabPositions);
  print('Fast ${stopwatch.elapsedMicroseconds} us');
}
