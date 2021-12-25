import '../utils.dart';

class Input {
  final int rowSize;
  final int colSize;
  final Map<Coordinate, String> state;

  Input(this.rowSize, this.colSize, this.state);
}

Future<Input> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();

  final rowSize = lines.length;
  final colSize = lines[0].length;
  final Map<Coordinate, String> state = Map();

  for (int row in range(rowSize)) {
    for (int col in range(colSize)) {
      if (lines[row][col] == 'v' || lines[row][col] == '>') {
        final c = Coordinate(col, row);
        state[c] = lines[row][col];
      }
    }
  }

  return Input(rowSize, colSize, state);
}
