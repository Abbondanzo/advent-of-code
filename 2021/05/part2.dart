import '../utils.dart';
import './part1.dart';

void main() async {
  final inputLines = readFile('5/input');
  final inputLineList = await inputLines.toList();

  final lines = inputLineList.map((line) => Line.fromInput(line));

  final pointMap = Map<Point, int>();
  lines.forEach((line) {
    final pointsOnLine = line.getPoints(false);
    pointsOnLine.forEach((point) {
      pointMap.update(point, (value) => value + 1, ifAbsent: () => 1);
    });
  });

  // At how many points do at least two lines overlap?
  final overlapTwoCount = pointMap.values.where((value) => value >= 2).length;
  print('Number of two or more point overlaps $overlapTwoCount');
}
