import '../utils.dart';

Future<void> parseInput() async {
  final inputLines = readFile('10/input');
  final inputLineList = await inputLines.toList();
}

void main() async {
  final inputLines = await parseInput();
}
