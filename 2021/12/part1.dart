import 'dart:collection';

import '../utils.dart';

Future<void> parseInput() async {
  final inputLines = readFile('11/input');
  final inputLineList = await inputLines.toList();
}

void main() async {
  final inputLines = await parseInput();
}
