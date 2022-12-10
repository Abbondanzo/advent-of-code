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
  List<String> rows = [];
  String row = "";
  for (int i = 0; i < 240; i++) {
    final crt = i % 40;
    final position = processor.runToCycle(i + 1);
    if (crt >= position - 1 && crt <= position + 1) {
      row += "#";
    } else {
      row += ".";
    }
    if ((i + 1) % 40 == 0) {
      rows.add(row);
      row = "";
    }
  }
  print(rows.join("\n"));
}
