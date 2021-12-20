import './parse.dart';
import './part1.dart';

void main() async {
  final input = await parseInput('19/input');
  final scanners = assembleScanners(input);

  int largestManhatten = 0;
  for (int i = 0; i < scanners.length; i++) {
    for (int j = 0; j < scanners.length; j++) {
      final manhatten =
          scanners[i].position.manhattenDistance(scanners[j].position);
      if (manhatten > largestManhatten) {
        largestManhatten = manhatten;
      }
    }
  }

  print(largestManhatten);
}
