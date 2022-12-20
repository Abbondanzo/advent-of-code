import 'package:equatable/equatable.dart';

import '../utils.dart';

typedef Input = List<int>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) {
    return int.parse(line);
  }).toList();
}
