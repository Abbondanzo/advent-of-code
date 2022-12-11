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

class Factorable {
  Map<int, bool> dividends = {
    2: false,
    3: false,
    5: false,
    7: false,
    11: false,
    13: false,
    17: false,
    19: false,
    23: false
  };

  Factorable(int num) {
    _fromNum(num);
    assert(_toNum() == num);
  }

  void add(int num) {
    final total = _toNum() + num;
    _fromNum(total);
  }

  void multiply(int num) {
    assert(dividends.containsKey(num));
    dividends[num] = true;
  }

  void pow(int num) {
    // Do nothing
  }

  bool isDivisible(int num) {
    assert(dividends.containsKey(num));
    return dividends[num]!;
  }

  void _fromNum(int num) {
    dividends.forEach((key, value) {
      while (num % key == 0) {
        num = (num / key).floor();
        dividends[key] = true;
      }
    });
  }

  int _toNum() {
    int num = 1;
    dividends.forEach((key, value) {
      num *= key;
    });
    return num;
  }
}

class Monkey {
  final List<Factorable> items;
  final void Function(Factorable) operation;
  final int Function(Factorable) test;
  int interactions = 0;

  Monkey(this.items, this.operation, this.test);

  void runRound(List<Monkey> allMonkeys) {
    while (items.isNotEmpty) {
      interactions++;
      final item = items.removeAt(0);
      operation(item);
      final nextMonkeyIdx = test(item);
      final nextMonkey = allMonkeys[nextMonkeyIdx];
      print("to $nextMonkeyIdx");
      nextMonkey.items.add(item);
    }
  }
}

// List<double> fromInts(List<int> ints) {
//   return ints.map((num) => BigInt.from(num)).toList();
// }

List<Factorable> toFactorables(List<int> ints) {
  return ints.map((num) => Factorable(num)).toList();
}

void main() async {
  // final input = await parseInput('11/input');

  // final List<Monkey> monkeys = [
  //   Monkey([66, 59, 64, 51], (int worryLevel) => worryLevel * 3,
  //       (int worryLevel) => worryLevel % 2 == 0 ? 1 : 4),
  //   Monkey([67, 61], (int worryLevel) => worryLevel * 19,
  //       (int worryLevel) => worryLevel % 7 == 0 ? 3 : 5),
  //   Monkey([86, 93, 80, 70, 71, 81, 56], (int worryLevel) => worryLevel + 2,
  //       (int worryLevel) => worryLevel % 11 == 0 ? 4 : 0),
  //   Monkey([94], (int worryLevel) => worryLevel * worryLevel,
  //       (int worryLevel) => worryLevel % 19 == 0 ? 7 : 6),
  //   Monkey([71, 92, 64], (int worryLevel) => worryLevel + 8,
  //       (int worryLevel) => worryLevel % 3 == 0 ? 5 : 1),
  //   Monkey([58, 81, 92, 75, 56], (int worryLevel) => worryLevel + 6,
  //       (int worryLevel) => worryLevel % 5 == 0 ? 3 : 6),
  //   Monkey([82, 98, 77, 94, 86, 81], (int worryLevel) => worryLevel + 7,
  //       (int worryLevel) => worryLevel % 17 == 0 ? 7 : 2),
  //   Monkey([54, 95, 70, 93, 88, 93, 63, 50], (int worryLevel) => worryLevel + 4,
  //       (int worryLevel) => worryLevel % 13 == 0 ? 2 : 0),
  // ];

  final List<Monkey> monkeys = [
    Monkey(toFactorables([79, 98]), (worryLevel) => worryLevel.multiply(19),
        (worryLevel) => worryLevel.isDivisible(23) ? 2 : 3),
    Monkey(toFactorables([54, 65, 75, 74]), (worryLevel) => worryLevel.add(6),
        (worryLevel) => worryLevel.isDivisible(19) ? 2 : 0),
    Monkey(toFactorables([79, 60, 97]), (worryLevel) => worryLevel.pow(2),
        (worryLevel) => worryLevel.isDivisible(13) ? 1 : 3),
    Monkey(toFactorables([74]), (worryLevel) => worryLevel.add(3),
        (worryLevel) => worryLevel.isDivisible(17) ? 0 : 1),
  ];

  for (int i in range(20)) {
    print(i);
    for (Monkey monkey in monkeys) {
      monkey.runRound(monkeys);
    }
  }

  final worryLevels = monkeys.map((m) => m.interactions).toList();
  print(worryLevels);
  // worryLevels.sort((a, b) => b.compareTo(a));
  // print(worryLevels[0] * worryLevels[1]);
}
