import '../utils.dart';

Future<List<Pair<String, int>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return inputLineList.map((line) {
    final rawChars = line.split(' ');
    assert(rawChars.length == 2);
    return Pair(rawChars[0], int.parse(rawChars[1]));
  }).toList();
}

void main() async {
  final input = await parseInput('09/input');
}
