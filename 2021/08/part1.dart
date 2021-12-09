import '../utils.dart';

class InputLine {
  final List<String> digits;
  final List<String> code;

  InputLine(this.digits, this.code);
}

Future<List<InputLine>> parseInput() async {
  final inputLines = readFile('8/input');
  final inputLineList = await inputLines.toList();

  return inputLineList.map((line) {
    final sections = line.split(' | ');
    assert(sections.length == 2);
    return InputLine(sections[0].split(' '), sections[1].split(' '));
  }).toList();
}

int countUniqueDigits(List<String> digits) {
  int count = 0;
  digits.forEach((element) {
    // It's a 1 (l=2), 4 (l=4), 7 (l=3), or 8 (l=7)
    if (element.length == 2 ||
        element.length == 4 ||
        element.length == 3 ||
        element.length == 7) {
      count++;
    }
  });
  return count;
}

void main() async {
  final inputLines = await parseInput();
  final int uniquesCount = inputLines.fold(
      0,
      (previousValue, element) =>
          previousValue + countUniqueDigits(element.code));
  // In the output values, how many times do digits 1, 4, 7, or 8 appear?
  print(uniquesCount);
}
