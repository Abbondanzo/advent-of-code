import '../utils.dart';

Future<List<List<int>>> parseInput() async {
  final inputLines = readFile('9/input');
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) {
    return line.split('').map((char) => int.parse(char)).toList();
  }).toList();
}

bool isLowPoint(List<List<int>> input, int row, int column) {
  final point = input[row][column];
  final higherTop = row == 0 || input[row - 1][column] > point;
  if (!higherTop) return false;
  final higherLeft = column == 0 || input[row][column - 1] > point;
  if (!higherLeft) return false;
  final higherRight =
      column == input[0].length - 1 || input[row][column + 1] > point;
  if (!higherRight) return false;
  final higherBottom =
      row == input.length - 1 || input[row + 1][column] > point;
  return higherBottom;
}

List<int> bruteForce(List<List<int>> input) {
  final List<int> lowPoints = [];
  input.asMap().forEach((rowIndex, row) {
    row.asMap().forEach((colIndex, point) {
      if (isLowPoint(input, rowIndex, colIndex)) {
        lowPoints.add(point);
      }
    });
  });
  return lowPoints;
}

void main() async {
  final inputLines = await parseInput();
  final lowPoints = bruteForce(inputLines);

  /// The risk level of a low point is 1 plus its height
  final int riskLevelSum = lowPoints.fold(
      0, (previousValue, element) => previousValue + element + 1);

  /// What is the sum of the risk levels of all low points on your heightmap?
  print(riskLevelSum);
}
