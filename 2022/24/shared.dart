import "../utils.dart";

typedef Input = Set<Coordinate>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return {};
}
