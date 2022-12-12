import './shared.dart';
import '../utils.dart';

Coordinate findStart(List<List<String>> input) {
  for (int y in range(input.length)) {
    final row = input[y];
    for (int x in range(row.length)) {
      final char = row[x];
      if (char == "S") {
        return Coordinate(x, y);
      }
    }
  }
  throw Error();
}

void main() async {
  final input = await parseInput('12/input');
  final start = findStart(input);
  final path = bfs(start, input);
  print(path.length - 1);
}
