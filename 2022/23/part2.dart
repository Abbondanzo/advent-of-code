import "./shared.dart";
import "../utils.dart";

void main() async {
  final input = await parseInput("23/input");

  Set<Coordinate> elves = input;
  int round = 0;
  while (true) {
    final proposals = generateProposals(elves, round);
    if (proposals.length == 0) {
      break;
    }
    round++;
    elves.removeAll(proposals.keys);
    elves.addAll(proposals.values);
  }

  print(round + 1);
}
