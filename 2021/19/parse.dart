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

  Coord3D operator +(Coord3D other) {
    return Coord3D(x + other.x, y + other.y, z + other.z);
  }

  Coord3D operator -(Coord3D other) {
    return Coord3D(x - other.x, y - other.y, z - other.z);
  }

  List<int> toJSON() {
    return [x, y, z];
  }

  int manhattenDistance(Coord3D other) {
    return (x - other.x).abs() + (y - other.y).abs() + (z - other.z).abs();
  }
}

typedef DisplacementMap = Map<Coord3D, List<Displacement>>;
typedef Displacement = int;

typedef DistanceMap = Map<Coord3D, List<Distance>>;
typedef Distance = int;

class Scanner {
  final List<Coord3D> beacons;

  DistanceMap? _xDistances;
  DistanceMap? _yDistances;
  DistanceMap? _zDistances;

  Scanner(this.beacons);

  DistanceMap get xDistances {
    if (_xDistances == null) {
      _xDistances = _getDistances(beacons, (coord) => coord.x);
    }
    return _xDistances!;
  }

  DisplacementMap get xDisplacements {
    return _getDisplacements(xDistances);
  }

  DistanceMap get yDistances {
    if (_yDistances == null) {
      _yDistances = _getDistances(beacons, (coord) => coord.y);
    }
    return _yDistances!;
  }

  DisplacementMap get yDisplacements {
    return _getDisplacements(yDistances);
  }

  DistanceMap get zDistances {
    if (_zDistances == null) {
      _zDistances = _getDistances(beacons, (coord) => coord.z);
    }
    return _zDistances!;
  }

  DisplacementMap get zDisplacements {
    return _getDisplacements(zDistances);
  }

  static DistanceMap _getDistances(
      List<Coord3D> beacons, int Function(Coord3D coord3d) func) {
    final DistanceMap displacementMap = Map();
    beacons.forEach((beacon) {
      final currentPos = func(beacon);
      final displacements = beacons.map((otherBeacon) {
        final otherPos = func(otherBeacon);
        return currentPos - otherPos;
      }).toList();
      displacementMap[beacon] = displacements;
    });
    return displacementMap;
  }

  static DisplacementMap _getDisplacements(DistanceMap distances) {
    return distances
        .map((key, value) => MapEntry(key, value.map((v) => v.abs()).toList()));
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

class OutputScanner {
  final Coord3D position;
  final List<Coord3D> beacons;

  OutputScanner(this.position, this.beacons);
}
