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
  final Coord3D coord;
  final int displacement;

  Displacement(this.coord, this.displacement);

  @override
  List<Object?> get props => [displacement];

  @override
  String toString() {
    return 'Displacement($displacement, beacon: $coord)';
  }
}

class Scanner {
  final List<Coord3D> beacons;
  final List<Displacement> xDisplacements;
  final List<Displacement> yDisplacements;
  final List<Displacement> zDisplacements;

  Scanner(this.beacons)
      : xDisplacements = _getDisplacements(beacons, (coord) => coord.x),
        yDisplacements = _getDisplacements(beacons, (coord) => coord.y),
        zDisplacements = _getDisplacements(beacons, (coord) => coord.z);

  static List<Displacement> _getDisplacements(
      List<Coord3D> beacons, int Function(Coord3D coord3d) func) {
    final indexedValues = beacons.map(func).toList().asMap().entries.toList();
    indexedValues.sort(((a, b) => a.value.compareTo(b.value)));
    final startPos = indexedValues.first.value;
    final offsetValues = indexedValues.map((indexedValue) {
      return MapEntry(indexedValue.key, (startPos - indexedValue.value).abs());
    });
    MapEntry<int, int>? previous;
    final List<Displacement> nextDisplacements = [];
    offsetValues.forEach((offset) {
      if (previous != null) {
        nextDisplacements.add(
            Displacement(beacons[offset.key], offset.value - previous!.value));
      }
      previous = offset;
    });
    return nextDisplacements;
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
