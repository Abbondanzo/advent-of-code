import './shared.dart';
import '../utils.dart';

void main() async {
  final monkeys = await parseInput('11/input');

  for (int _ in range(20)) {
    for (Monkey monkey in monkeys) {
      monkey.runRound(monkeys, divisor: 3);
    }
  }

  final worryLevels = monkeys.map((m) => m.interactions).toList();
  worryLevels.sort((a, b) => b.compareTo(a));
  print(worryLevels[0] * worryLevels[1]);
}
