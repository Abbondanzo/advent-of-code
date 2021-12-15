import '../utils.dart';

Future<void> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  print(inputLineList);
}

void main() async {
  final input = await parseInput('15/demo');
}
