import '../utils.dart';

Future<List<List<String>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) => line.split("")).toList();
}
