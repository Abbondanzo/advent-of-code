import '../utils.dart';
import './shared.dart';

Future<List<Instruction>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return inputLineList.map((line) {
    final rawChars = line.split(' ');
    if (rawChars.length == 1) {
      return Noop();
    } else {
      assert(rawChars.length == 2);
      return AddX(int.parse(rawChars[1]));
    }
  }).toList();
}

void main() async {
  final input = await parseInput('10/input');
  final processor = SignalProcessor();
  processor.setInstructions(input);
  int total = 0;
  for (int i = 20; i < 221; i += 40) {
    total += processor.runToCycle(i) * i;
  }
  print(total);
}
