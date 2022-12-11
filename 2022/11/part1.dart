import 'dart:convert';

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
  final int Function(int) test;
  int interactions = 0;

  Monkey(this.items, this.operation, this.test);

  void runRound(List<Monkey> allMonkeys) {
    while (items.isNotEmpty) {
      interactions++;
      final item = items.removeAt(0);
      int newWorry = operation(item);
      newWorry = (newWorry / 3).floor();
      final nextMonkeyIdx = test(newWorry);
      final nextMonkey = allMonkeys[nextMonkeyIdx];
      nextMonkey.items.add(newWorry);
    }
  }
}

void main() async {
  // final input = await parseInput('11/input');

  final List<Monkey> monkeys = [
    Monkey([66, 59, 64, 51], (int worryLevel) => worryLevel * 3,
        (int worryLevel) => worryLevel % 2 == 0 ? 1 : 4),
    Monkey([67, 61], (int worryLevel) => worryLevel * 19,
        (int worryLevel) => worryLevel % 7 == 0 ? 3 : 5),
    Monkey([86, 93, 80, 70, 71, 81, 56], (int worryLevel) => worryLevel + 2,
        (int worryLevel) => worryLevel % 11 == 0 ? 4 : 0),
    Monkey([94], (int worryLevel) => worryLevel * worryLevel,
        (int worryLevel) => worryLevel % 19 == 0 ? 7 : 6),
    Monkey([71, 92, 64], (int worryLevel) => worryLevel + 8,
        (int worryLevel) => worryLevel % 3 == 0 ? 5 : 1),
    Monkey([58, 81, 92, 75, 56], (int worryLevel) => worryLevel + 6,
        (int worryLevel) => worryLevel % 5 == 0 ? 3 : 6),
    Monkey([82, 98, 77, 94, 86, 81], (int worryLevel) => worryLevel + 7,
        (int worryLevel) => worryLevel % 17 == 0 ? 7 : 2),
    Monkey([54, 95, 70, 93, 88, 93, 63, 50], (int worryLevel) => worryLevel + 4,
        (int worryLevel) => worryLevel % 13 == 0 ? 2 : 0),
  ];

  // final List<Monkey> monkeys = [
  //   Monkey([79, 98], (int worryLevel) => worryLevel * 19,
  //       (int worryLevel) => worryLevel % 23 == 0 ? 2 : 3),
  //   Monkey([54, 65, 75, 74], (int worryLevel) => worryLevel + 6,
  //       (int worryLevel) => worryLevel % 19 == 0 ? 2 : 0),
  //   Monkey([79, 60, 97], (int worryLevel) => worryLevel * worryLevel,
  //       (int worryLevel) => worryLevel % 13 == 0 ? 1 : 3),
  //   Monkey([74], (int worryLevel) => worryLevel + 3,
  //       (int worryLevel) => worryLevel % 17 == 0 ? 0 : 1),
  // ];

  for (int _ in range(20)) {
    for (Monkey monkey in monkeys) {
      monkey.runRound(monkeys);
    }
  }

  final worryLevels = monkeys.map((m) => m.interactions).toList();
  worryLevels.sort((a, b) => b.compareTo(a));
  print(worryLevels[0] * worryLevels[1]);
}
