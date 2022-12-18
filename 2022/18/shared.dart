import 'package:equatable/equatable.dart';

import '../utils.dart';

int exteriorSides(List<Coordinate3D> input) {
  int touching = 0;
  final Set<Coordinate3D> parsed = Set();
  for (final coord in input) {
    for (final parse in parsed) {
      if (parse.touching(coord)) {
        touching++;
      }
    }
    parsed.add(coord);
  }
  final totalSides = parsed.length * 6;
  final hiddenSides = touching * 2;
  return totalSides - hiddenSides;
}

class Coordinate3D extends Equatable {
  final int x;
  final int y;
  final int z;

  Coordinate3D(this.x, this.y, this.z);

  @override
  List<Object?> get props => [x, y, z];

  @override
  String toString() {
    return "($x,$y,$z)";
  }

  bool touching(Coordinate3D other) {
    final distance = [
      (x - other.x).abs(),
      (y - other.y).abs(),
      (z - other.z).abs()
    ];
    final total = distance.reduce((value, element) => value + element);
    return total == 1;
  }
}

typedef Input = List<Coordinate3D>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) {
    final rawValues =
        line.split(",").map((maybeInt) => int.parse(maybeInt)).toList();
    assert(rawValues.length == 3);
    return Coordinate3D(rawValues[0], rawValues[1], rawValues[2]);
  }).toList();
}
