import './part1.dart';

String replaceCharAt(String input, int index, String newChar) {
  return input.substring(0, index) + newChar + input.substring(index + 1);
}

void printCoords(Set<Coord> coords) {
  /// First, determine string sizes
  int maxX = 0;
  int maxY = 0;
  coords.forEach((coord) {
    if (coord.x > maxX) {
      maxX = coord.x + 1;
    }
    if (coord.y > maxY) {
      maxY = coord.y + 1;
    }
  });

  /// Now, write to lines
  final List<String> lines = List.filled(maxY, '.' * (maxX));
  coords.forEach((coord) {
    lines[coord.y] = replaceCharAt(lines[coord.y], coord.x, '#');
  });

  /// Finally, print all the lines
  lines.forEach((line) {
    print(line);
  });
}

void main() async {
  final input = await parseInput('13/input');
  final finalCoords = input.runFolds();

  printCoords(finalCoords);
}
