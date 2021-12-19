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

class Scanner {
  final List<Coord3D> beacons;

  Scanner(this.beacons);
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
