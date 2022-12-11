import '../utils.dart';

Future<List<dynamic>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  for (int i = 0; i < inputLineList.length; i += 7) {
    final startingItemsAfter = inputLineList[i + 1].split("Starting items:");
    print(inputLineList[i + 1]);
  }
  return inputLineList.map((line) {}).toList();
}

class Monkey {
  final List<int> items;
  final int Function(int) operation;
  final int dividendTest;
  final int trueTest;
  final int falseTest;
  int interactions = 0;

  Monkey(this.items, this.operation, this.dividendTest, this.trueTest,
      this.falseTest);

  void runRound(List<Monkey> allMonkeys, int leastCommonDenominiator) {
    while (items.isNotEmpty) {
      interactions++;
      final item = items.removeAt(0);
      final newWorry = operation(item) % leastCommonDenominiator;
      final nextMonkeyIdx = newWorry % dividendTest == 0 ? trueTest : falseTest;
      final nextMonkey = allMonkeys[nextMonkeyIdx];
      nextMonkey.items.add(newWorry);
    }
  }
}

// List<double> fromInts(List<int> ints) {
//   return ints.map((num) => BigInt.from(num)).toList();
// }

void main() async {
  // final input = await parseInput('11/input');

  final List<Monkey> monkeys = [
    Monkey([66, 59, 64, 51], (int worryLevel) => worryLevel * 3, 2, 1, 4),
    Monkey([67, 61], (int worryLevel) => worryLevel * 19, 7, 3, 5),
    Monkey([86, 93, 80, 70, 71, 81, 56], (int worryLevel) => worryLevel + 2, 11,
        4, 0),
    Monkey([94], (int worryLevel) => worryLevel * worryLevel, 19, 7, 6),
    Monkey([71, 92, 64], (int worryLevel) => worryLevel + 8, 3, 5, 1),
    Monkey([58, 81, 92, 75, 56], (int worryLevel) => worryLevel + 6, 5, 3, 6),
    Monkey(
        [82, 98, 77, 94, 86, 81], (int worryLevel) => worryLevel + 7, 17, 7, 2),
    Monkey([54, 95, 70, 93, 88, 93, 63, 50], (int worryLevel) => worryLevel + 4,
        13, 2, 0),
  ];

  // final List<Monkey> monkeys = [
  //   Monkey([79, 98], (worryLevel) => worryLevel * 19, 23, 2, 3),
  //   Monkey([54, 65, 75, 74], (worryLevel) => worryLevel + 6, 19, 2, 0),
  //   Monkey([79, 60, 97], (worryLevel) => worryLevel * worryLevel, 13, 1, 3),
  //   Monkey([74], (worryLevel) => worryLevel + 3, 17, 0, 1),
  // ];

  final leastCommonDenominiator = monkeys
      .map((monkey) => monkey.dividendTest)
      .reduce((value, element) => value * element);
  print(leastCommonDenominiator);

  for (int _ in range(10000)) {
    for (Monkey monkey in monkeys) {
      monkey.runRound(monkeys, leastCommonDenominiator);
    }
  }

  final worryLevels = monkeys.map((m) => m.interactions).toList();
  worryLevels.sort((a, b) => b.compareTo(a));
  print(worryLevels[0] * worryLevels[1]);
}
