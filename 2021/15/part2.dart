import './part1.dart';

/// Given the original input, expands it 5 times with increased risk
Input expandInput(Input input) {
  Input output = [];
  List.generate(5, (rowIncCount) {
    input.forEach((row) {
      final List<Coord> nextRow = [];
      List.generate(5, (colIncCount) {
        row.forEach((coord) {
          final incrementedRisk = coord.risk + rowIncCount + colIncCount;
          final nextRisk =
              incrementedRisk > 9 ? incrementedRisk % 9 : incrementedRisk;
          final newRow = coord.row + rowIncCount * input.length;
          final newCol = coord.col + colIncCount * row.length;
          nextRow.add(Coord(newRow, newCol, nextRisk));
        });
      });
      output.add(nextRow);
    });
  });
  return output;
}

void main() async {
  final input = await parseInput('15/input');
  final expandedInput = expandInput(input);
  Stopwatch stopwatch = new Stopwatch()..start();
  astar(expandedInput);
  print('executed in ${stopwatch.elapsed.inMilliseconds}ms');
}
