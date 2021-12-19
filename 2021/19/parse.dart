import 'package:equatable/equatable.dart';

import '../utils.dart';

class Coord3D extends Equatable {
  final int x;
  final int y;
  final int z;

  Coord3D(this.x, this.y, this.z);

  @override
  List<Object?> get props => [x, y, z];

  @override
  String toString() {
    return 'Coord3D($x, $y, $z)';
  }
}

class Displacement extends Equatable {
  final int coordIdx;
  final int displacement;

  Displacement(this.coordIdx, this.displacement);

  @override
  List<Object?> get props => [displacement];

  @override
  String toString() {
    return 'Displacement($displacement, beaconIdx: $coordIdx)';
  }
}

class Scanner {
  final List<Coord3D> beacons;
  final Set<Displacement> xDisplacements;
  final Set<Displacement> yDisplacements;
  final Set<Displacement> zDisplacements;

  Scanner(this.beacons)
      : xDisplacements = _getDisplacements(_getXCoords(beacons)),
        yDisplacements = _getDisplacements(_getYCoords(beacons)),
        zDisplacements = _getDisplacements(_getZCoords(beacons));

  static List<int> _getXCoords(List<Coord3D> coords) {
    return coords.map((coord) => coord.x).toList();
  }

  static List<int> _getYCoords(List<Coord3D> coords) {
    return coords.map((coord) => coord.y).toList();
  }

  static List<int> _getZCoords(List<Coord3D> coords) {
    return coords.map((coord) => coord.z).toList();
  }

  static Set<Displacement> _getDisplacements(List<int> values) {
    final indexedValues = values.asMap().entries.toList();
    indexedValues.sort(((a, b) => a.value.compareTo(b.value)));
    final startPos = indexedValues.first.value;
    final offsetValues = indexedValues.map((indexedValue) {
      return MapEntry(indexedValue.key, (startPos - indexedValue.value).abs());
    });
    MapEntry<int, int>? previous;
    final List<Displacement> nextDisplacements = [];
    offsetValues.forEach((offset) {
      if (previous != null) {
        nextDisplacements
            .add(Displacement(offset.key, offset.value - previous!.value));
      }
      previous = offset;
    });
    return nextDisplacements.toSet();
  }
}

typedef Input = List<Scanner>;

Future<Input> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();

  final scannerLineRegex = RegExp(r'--- scanner \d+ ---');

  final List<Scanner> scanners = [];
  List<Coord3D> beacons = [];

  lines.forEach((line) {
    if (scannerLineRegex.hasMatch(line)) {
      beacons = [];
    } else if (line == '') {
      scanners.add(Scanner(beacons));
    } else {
      final coords =
          line.split(',').map((strNum) => int.parse(strNum)).toList();
      assert(coords.length == 3);
      beacons.add(Coord3D(coords[0], coords[1], coords[2]));
    }
  });

  if (beacons.isNotEmpty) {
    scanners.add(Scanner(beacons));
  }

  return scanners;
}
