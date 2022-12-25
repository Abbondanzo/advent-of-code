import "./shared.dart";
import "../utils.dart";

void main() async {
  final input = await parseInput("24/demo");
  final finalSpot = Coordinate(input.width - 2, input.height - 2);
  final solution = timeToGoal(finalSpot, Coordinate(1, 0), input);
  print(solution.second);
}
