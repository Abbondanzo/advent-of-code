import '../utils.dart';

typedef Input = List<String>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return inputLineList;
}
