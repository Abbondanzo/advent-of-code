import './shared.dart';
import '../utils.dart';

List<Coordinate> findStarts(List<List<String>> input) {
  final List<Coordinate> starts = [];
  for (int y in range(input.length)) {
    final row = input[y];
    for (int x in range(row.length)) {
      final char = row[x];
      if (char == "a") {
        final pos = Coordinate(x, y);
        final ed = edges(pos, input);
        if (ed.any((el) => input[el.y][el.x] != "a")) {
          starts.add(pos);
        }
      }
    }
  }
  return starts;
}

void main() async {
  final input = await parseInput('12/input');
  final starts = findStarts(input);
  int lowest = 999999;
  for (Coordinate start in starts) {
    final lgth = bfs(start, input).length - 1;
    if (lgth < lowest) {
      lowest = lgth;
    }
  }
  print(lowest);
}
