import './shared.dart';

int? solveMonkey(String monkeyName, Input input) {
  if (monkeyName == "humn") return null;
  final selectedMonkey = input[monkeyName]!;
  if (selectedMonkey is FixedMonkey) {
    return selectedMonkey.value;
  } else if (selectedMonkey is OperationMonkey) {
    final firstMonkey = solveMonkey(selectedMonkey.first, input);
    final secondMonkey = solveMonkey(selectedMonkey.second, input);
    if (firstMonkey == null || secondMonkey == null) return null;
    int result;
    switch (selectedMonkey.op) {
      case "+":
        result = firstMonkey + secondMonkey;
        break;
      case "-":
        result = firstMonkey - secondMonkey;
        break;
      case "*":
        result = firstMonkey * secondMonkey;
        break;
      case "/":
        result = firstMonkey ~/ secondMonkey;
        break;
      default:
        throw Error();
    }
    final newMonkey = FixedMonkey(result);
    input[monkeyName] = newMonkey;
    return result;
  } else {
    throw Error();
  }
}

int solveYell(String monkeyName, Input input, int sum) {
  if (monkeyName == "humn") return sum;
  final selectedMonkey = input[monkeyName]!;
  if (selectedMonkey is OperationMonkey) {
    final first = solveMonkey(selectedMonkey.first, input);
    final second = solveMonkey(selectedMonkey.second, input);
    assert(first != null || second != null);
    int newSum;
    switch (selectedMonkey.op) {
      case "+":
        newSum = sum - (first ?? second)!;
        break;
      case "-":
        if (first != null) {
          newSum = first - sum;
        } else {
          newSum = sum + second!;
        }
        break;
      case "*":
        newSum = sum ~/ (first ?? second)!;
        break;
      case "/":
        if (first != null) {
          newSum = first ~/ sum;
        } else {
          newSum = sum * second!;
        }
        break;
      default:
        throw Error();
    }

    if (first == null) {
      return solveYell(selectedMonkey.first, input, newSum);
    } else {
      return solveYell(selectedMonkey.second, input, newSum);
    }
  } else {
    throw Error();
  }
}

void main() async {
  final input = await parseInput('21/input');
  final root = input["root"] as OperationMonkey;

  final first = solveMonkey(root.first, input);
  final second = solveMonkey(root.second, input);
  assert(first != null || second != null);

  int toYell;
  if (first == null) {
    toYell = solveYell(root.first, input, second!);
  } else {
    toYell = solveYell(root.second, input, first);
  }

  print(toYell);
}
