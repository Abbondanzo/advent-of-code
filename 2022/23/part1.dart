import "./shared.dart";
import "../utils.dart";

void main() async {
  final input = await parseInput("23/input");

  Set<Coordinate> elves = input;
  for (int round in range(10)) {
    final proposals = generateProposals(elves, round);
    elves.removeAll(proposals.keys);
    elves.addAll(proposals.values);
  }

  final min = getMinimums(elves);
  final max = getMaximums(elves);
  final totalX = max.x - min.x + 1;
  final totalY = max.y - min.y + 1;
  print(totalX * totalY - elves.length);
}
