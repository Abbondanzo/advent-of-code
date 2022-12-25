import "./shared.dart";
import "../utils.dart";

void main() async {
  final input = await parseInput("24/input");

  final firstSolution = timeToGoal(
      Coordinate(input.width - 2, input.height - 2), Coordinate(1, 0), input);
  print("Time to first move: ${firstSolution.second}");

  final secondSolution = timeToGoal(Coordinate(1, 1),
      Coordinate(input.width - 2, input.height - 1), firstSolution.first);
  print("Time to second move: ${secondSolution.second}");

  final thirdSolution = timeToGoal(
      Coordinate(input.width - 2, input.height - 2),
      Coordinate(1, 0),
      secondSolution.first);
  print("Time to third move: ${thirdSolution.second}");

  print(firstSolution.second + secondSolution.second + thirdSolution.second);
}
