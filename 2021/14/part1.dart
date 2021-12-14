import '../utils.dart';

class Input {
  final String polyTemplate;
  final Map<String, String> insertionRules;

  Input(this.polyTemplate, this.insertionRules);

  String runSteps(int numSteps) {
    String toModify = this.polyTemplate;
    List.generate(numSteps, (_) {
      String stepOutput = toModify[0];
      for (int i = 0; i < toModify.length - 1; i++) {
        final pairing = toModify.substring(i, i + 2);
        final toInsert = this.insertionRules[pairing]!;
        stepOutput += toInsert;
        stepOutput += pairing[1];
      }
      toModify = stepOutput;
    });
    return toModify;
  }
}

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final polyTemplate = inputLineList[0];
  final insertionRules = Map<String, String>();
  inputLineList.sublist(2).forEach((line) {
    final ruleSubStr = line.split(' -> ');
    assert(ruleSubStr.length == 2);
    insertionRules[ruleSubStr[0]] = ruleSubStr[1];
  });
  return Input(polyTemplate, insertionRules);
}

Map<String, int> elementCounts(String input) {
  final counts = Map<String, int>();
  input.split('').forEach((char) {
    counts.update(char, (value) => value + 1, ifAbsent: () => 1);
  });
  return counts;
}

int mostCommonMinusLeastCommon(String input) {
  final counts = elementCounts(input);
  int? smallest;
  int? largest;
  counts.values.forEach((count) {
    if (smallest == null || count < smallest!) {
      smallest = count;
    }
    if (largest == null || count > largest!) {
      largest = count;
    }
  });
  return largest! - smallest!;
}

void main() async {
  final input = await parseInput('14/input');
  final outputStr = input.runSteps(10);
  final output = mostCommonMinusLeastCommon(outputStr);
  print(output);
}
