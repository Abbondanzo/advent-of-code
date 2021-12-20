import 'package:equatable/equatable.dart';
import 'package:linalg/linalg.dart';

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

  Vector toVector() {
    return Vector.row([x.toDouble(), y.toDouble(), z.toDouble()]);
  }
}

typedef DisplacementMap = Map<Coord3D, List<Displacement>>;
typedef Displacement = int;

class Scanner {
  final List<Coord3D> beacons;
  final DisplacementMap xDisplacements;
  final DisplacementMap yDisplacements;
  final DisplacementMap zDisplacements;

  Coord3D? origin;
  List<Coord3D>? transformedBeacons;

  Scanner(this.beacons)
      : xDisplacements = _getDisplacements(beacons, (coord) => coord.x),
        yDisplacements = _getDisplacements(beacons, (coord) => coord.y),
        zDisplacements = _getDisplacements(beacons, (coord) => coord.z);

  static DisplacementMap _getDisplacements(
      List<Coord3D> beacons, int Function(Coord3D coord3d) func) {
    final DisplacementMap displacementMap = Map();
    beacons.forEach((beacon) {
      final currentPos = func(beacon);
      final displacements = beacons.map((otherBeacon) {
        final otherPos = func(otherBeacon);
        return (currentPos - otherPos).abs();
      }).toList();
      displacementMap[beacon] = displacements;
    });
    return displacementMap;
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
