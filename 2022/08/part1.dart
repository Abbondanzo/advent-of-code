import '../utils.dart';

Future<List<List<int>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  return inputLineList.map((line) {
    return line.split('').map((char) => int.parse(char)).toList();
  }).toList();
}

int getVisibleInnerTrees(List<List<int>> input) {
  Set<Coordinate> innerTrees = new Set();

  for (int rowIdx in range(1, input.length - 1)) {
    final row = input[rowIdx];
    int minHeight = row[0];

    // Look left to right
    for (int colIdx in range(1, row.length - 1)) {
      final treeHeight = row[colIdx];
      if (treeHeight > minHeight) {
        minHeight = treeHeight;
        innerTrees.add(Coordinate(colIdx, rowIdx));
      }
    }

    // Look right to left
    final maxHeight = minHeight;
    minHeight = row[row.length - 1];
    for (int colIdx in range(1, row.length - 1).reversed) {
      final treeHeight = row[colIdx];
      if (treeHeight > minHeight) {
        minHeight = treeHeight;
        innerTrees.add(Coordinate(colIdx, rowIdx));
      }
      if (treeHeight == maxHeight) {
        break;
      }
    }
  }

  for (int colIdx in range(1, input[0].length - 1)) {
    // Look top to bottom
    int minHeight = input[0][colIdx];
    for (int rowIdx in range(1, input.length - 1)) {
      final treeHeight = input[rowIdx][colIdx];
      if (treeHeight > minHeight) {
        minHeight = treeHeight;
        innerTrees.add(Coordinate(colIdx, rowIdx));
      }
    }

    // Look bottom to top
    final maxHeight = minHeight;
    minHeight = input[input.length - 1][colIdx];
    for (int rowIdx in range(1, input.length - 1).reversed) {
      final treeHeight = input[rowIdx][colIdx];
      if (treeHeight > minHeight) {
        minHeight = treeHeight;
        innerTrees.add(Coordinate(colIdx, rowIdx));
      }
      if (treeHeight == maxHeight) {
        break;
      }
    }
  }

  return innerTrees.length;
}

void main() async {
  final input = await parseInput('08/input');
  final innerTreeCount = getVisibleInnerTrees(input);
  final output = innerTreeCount + input.length * 2 + (input[0].length - 2) * 2;
  print(output);
}
