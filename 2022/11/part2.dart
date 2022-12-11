import './shared.dart';
import '../utils.dart';

void main() async {
  final monkeys = await parseInput('11/input');

  final leastCommonDenominiator = monkeys
      .map((monkey) => monkey.dividendTest)
      .reduce((value, element) => value * element);

  for (int _ in range(10000)) {
    for (Monkey monkey in monkeys) {
      monkey.runRound(monkeys,
          leastCommonDenominiator: leastCommonDenominiator);
    }
  }

  final worryLevels = monkeys.map((m) => m.interactions).toList();
  worryLevels.sort((a, b) => b.compareTo(a));
  print(worryLevels[0] * worryLevels[1]);
}
