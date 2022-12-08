import '../utils.dart';

Future<List<List<int>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return inputLineList.map((line) {
    return line.split('').map((char) => int.parse(char)).toList();
  }).toList();
}

void main() async {
  final input = await parseInput('09/demo');
}
