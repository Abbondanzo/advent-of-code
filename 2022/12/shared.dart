import '../utils.dart';

Future<List<dynamic>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  return inputLineList;
}
