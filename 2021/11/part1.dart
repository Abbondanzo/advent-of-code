import 'dart:collection';

import '../utils.dart';

Future<List<List<String>>> parseInput() async {
  final inputLines = readFile('10/input');
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) => line.split('')).toList();
}

void main() async {
  final inputLines = await parseInput();
}
