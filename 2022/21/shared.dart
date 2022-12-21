import '../utils.dart';

class Monkey {}

class FixedMonkey extends Monkey {
  final int value;

  FixedMonkey(this.value);

  @override
  String toString() {
    return "$value";
  }
}

class OperationMonkey extends Monkey {
  String first;
  String second;
  String op;

  OperationMonkey(this.first, this.second, this.op);

  @override
  String toString() {
    return "$first $op $second";
  }
}

typedef Input = Map<String, Monkey>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final Input map = Map();
  inputLineList.forEach((line) {
    final splitLine = line.split(": ");
    assert(splitLine.length == 2);
    final monkeyName = splitLine[0];

    final maybeNumber = int.tryParse(splitLine[1]);
    if (maybeNumber != null) {
      map[monkeyName] = FixedMonkey(maybeNumber);
    } else {
      final ops = splitLine[1].split(" ");
      assert(ops.length == 3);
      map[monkeyName] = OperationMonkey(ops[0], ops[2], ops[1]);
    }
  });
  return map;
}
