import '../utils.dart';

class Monkey {
  final List<int> items;
  final int Function(int) operation;
  final int dividendTest;
  final int trueTest;
  final int falseTest;
  int interactions = 0;

  Monkey(this.items, this.operation, this.dividendTest, this.trueTest,
      this.falseTest);

  void runRound(List<Monkey> allMonkeys,
      {int? divisor = null, int? leastCommonDenominiator = null}) {
    while (items.isNotEmpty) {
      interactions++;
      final item = items.removeAt(0);
      int newWorry = operation(item);
      if (divisor != null) {
        newWorry = (newWorry / divisor).floor();
      }
      if (leastCommonDenominiator != null) {
        newWorry = newWorry % leastCommonDenominiator;
      }
      final nextMonkeyIdx = newWorry % dividendTest == 0 ? trueTest : falseTest;
      final nextMonkey = allMonkeys[nextMonkeyIdx];
      nextMonkey.items.add(newWorry);
    }
  }
}

final digitMatch = new RegExp(r'\d+');

int Function(int) _parseOperation(String line) {
  final match = new RegExp(r'new = old (.) (\w+)').firstMatch(line)!;
  final op = match.group(1)!;
  final factor = int.tryParse(match.group(2)!);
  return (old) {
    final by = factor ?? old;
    if (op == "+") {
      return old + by;
    } else {
      return old * by;
    }
  };
}

Monkey _parseMonkey(List<String> lines) {
  assert(lines.length == 6);
  final startingItems = digitMatch
      .allMatches(lines[1])
      .map((match) => match.group(0))
      .map((element) => int.parse(element!))
      .toList();
  final operation = _parseOperation(lines[2]);
  final test = int.parse(digitMatch.firstMatch(lines[3])!.group(0)!);
  final trueTest = int.parse(digitMatch.firstMatch(lines[4])!.group(0)!);
  final falseTest = int.parse(digitMatch.firstMatch(lines[5])!.group(0)!);
  return Monkey(startingItems, operation, test, trueTest, falseTest);
}

Future<List<Monkey>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  inputLineList.removeWhere((line) => line.trim() == "");
  final List<Monkey> monkeys = [];
  for (int i = 0; i < inputLineList.length; i += 6) {
    monkeys.add(_parseMonkey(inputLineList.sublist(i, i + 6)));
  }
  return monkeys;
}
