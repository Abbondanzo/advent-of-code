import "./shared.dart";

int solveMonkey(String monkeyName, Input input) {
  final selectedMonkey = input[monkeyName]!;
  if (selectedMonkey is FixedMonkey) {
    return selectedMonkey.value;
  } else if (selectedMonkey is OperationMonkey) {
    final firstMonkey = solveMonkey(selectedMonkey.first, input);
    final secondMonkey = solveMonkey(selectedMonkey.second, input);
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

void main() async {
  final input = await parseInput("21/input");
  final result = solveMonkey("root", input);
  print(result);
}
