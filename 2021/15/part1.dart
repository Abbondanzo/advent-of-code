import 'package:equatable/equatable.dart';

import '../utils.dart';

typedef Input = List<List<Coord>>;

class Coord extends Equatable {
  final int row;
  final int col;
  final int risk;

  Coord(this.row, this.col, this.risk);

  @override
  List<Object?> get props => [row, col, risk];

  @override
  String toString() {
    return 'Coord($row, $col, $risk)';
  }

  bool isGoal(Input input) {
    return manhattenDistance(input, this) == 0;
  }

  List<Coord> neighbors(Input input) {
    final List<Coord> neighborList = [];

    /// Add above
    if (this.row > 0) {
      neighborList.add(input[this.row - 1][this.col]);
    }

    /// Add left
    if (this.col > 0) {
      neighborList.add(input[this.row][this.col - 1]);
    }

    /// Add bottom
    if (this.row < input.length - 1) {
      neighborList.add(input[this.row + 1][this.col]);
    }

    /// Add right
    if (this.col < input[0].length - 1) {
      neighborList.add(input[this.row][this.col + 1]);
    }

    return neighborList;
  }
}

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  final Input output = [];
  inputLineList.asMap().forEach((rowIndex, line) {
    final List<Coord> row = [];
    line
        .split('')
        .map((risk) => int.parse(risk))
        .toList()
        .asMap()
        .forEach((colIndex, risk) {
      row.add(Coord(rowIndex, colIndex, risk));
    });
    output.add(row);
  });

  return output;
}

void dijkstra(Input input) {
  final Map<Coord, int> dist = Map();
  final Map<Coord, Coord> prev = Map();

  /// Set the distance to each vertex as "infinity"
  input.forEach((row) {
    row.forEach((coord) {});
  });
}

int manhattenDistance(Input input, Coord coord) {
  final largestRowIndex = input.length - 1;
  final largestColIndex = input[0].length - 1;
  return largestRowIndex - coord.row + largestColIndex - coord.col;
}

extension PriorityMap on Map<Coord, int> {
  MapEntry<Coord, int> lowestValue() {
    final entryList = this.entries.toList();
    entryList.sort((a, b) => a.value.compareTo(b.value));
    return entryList.first;
  }
}

Coord lowestFScore(List<Coord> open, Map<Coord, int> fScore) {
  Coord? lowestScoring;
  open.forEach((element) {
    if (lowestScoring == null ||
        fScore.containsKey(element) &&
            fScore[element]! < fScore[lowestScoring]!) {
      lowestScoring = element;
    }
  });
  return lowestScoring ?? open.first;
}

void astar(Input input) {
  final starterCoord = input[0][0];

  final List<Coord> open = [starterCoord];

  /// For a Coord key, the value is the cheapest Coord preceding it
  final Map<Coord, Coord> cameFrom = Map();

  /// The cost of getting from the starter coord to this one (based on risks)
  final gScore = Map<Coord, int>();
  gScore[starterCoord] = 0;

  /// Cost of gScore plus manhatten distance to finish
  final fScore = Map<Coord, int>();
  fScore[starterCoord] = manhattenDistance(input, starterCoord);

  while (open.isNotEmpty) {
    final smallestCoord = lowestFScore(open, fScore);
    if (smallestCoord.isGoal(input)) {
      int pathRisk = 0;
      Coord current = smallestCoord;
      while (cameFrom.containsKey(current)) {
        pathRisk += current.risk;
        current = cameFrom[current]!;
      }
      print(pathRisk);
      return;
    }

    open.remove(smallestCoord);
    smallestCoord.neighbors(input).forEach((neighbor) {
      final updatedGScore = gScore[smallestCoord]! + neighbor.risk;
      if (gScore[neighbor] == null || updatedGScore < gScore[neighbor]!) {
        cameFrom[neighbor] = smallestCoord;
        gScore[neighbor] = updatedGScore;
        fScore[neighbor] = updatedGScore + manhattenDistance(input, neighbor);
        if (!open.contains(neighbor)) {
          open.add(neighbor);
        }
      }
    });
  }

  throw Error();
}

void main() async {
  final input = await parseInput('15/input');
  astar(input);
}
