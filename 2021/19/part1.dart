import 'package:equatable/equatable.dart';
import 'package:linalg/linalg.dart';

import './parse.dart';

extension ListIntersect<E> on List<E> {
  List<E> intersection(List<E> other) {
    return this.where((element) => other.contains(element)).toList();
  }
}

Map<Coord3D, Coord3D>? checkForMatches(
    DisplacementMap scannerA, DisplacementMap scannerB) {
  Map<Coord3D, Coord3D> matches = Map();

  scannerA.entries.forEach((displacementEntry) {
    for (var otherDisplacementEntry in scannerB.entries) {
      if (displacementEntry.value
              .intersection(otherDisplacementEntry.value)
              .length >=
          12) {
        matches[displacementEntry.key] = otherDisplacementEntry.key;
        break;
      }
    }
  });

  if (matches.length >= 12) {
    return matches;
  }

  return null;
}

Coord3D applyTransformationMatrix(Matrix transformationMatrix, Coord3D coord) {
  final matrixToMult =
      Vector.column([...coord.toVector().toList(), 1.0]).toMatrix();
  final result = transformationMatrix * matrixToMult;
  final vectorNums = result.rowVector(0).toList();
  return Coord3D(
      vectorNums[0].toInt(), vectorNums[1].toInt(), vectorNums[2].toInt());
}

/// Given a mapping of coordinates `p` to their transformed counterparts `p'`,
/// determines the transformation matrix needed to convert `p` to `p'`; that is,
/// if you took the dot product of the returned transformation matrix and `p`,
/// it would yield `p'`.
///
/// The transformation matrix that this function yields is 4x4, where the final
/// column represents the `x`, `y`, `z` transformation (that is, the position
/// of the scanner of the values relative to the position of the scanner of the
/// keys)
Matrix determineTransformationMatrix(Map<Coord3D, Coord3D> mappings) {
  final List<Vector> p = [];
  final List<Vector> pPrime = [];

  mappings.entries.toList().take(3).forEach((entry) {
    p.add(entry.key.toVector());
    pPrime.add(entry.value.toVector());
  });

  List<List<double>> toMatrixInput(List<Vector> vectors) {
    return vectors.map((v) => v.toList()).toList();
  }

  Matrix stackInvertForRotation(List<Vector> vectors) {
    final crossProductList = vectors.sublist(1).map((v) {
      return v - vectors[0];
    }).toList();
    assert(crossProductList.length == 2);
    final crossProduct = crossProductList[0].crossProduct(crossProductList[1]);
    crossProductList.add(crossProduct);
    return Matrix(toMatrixInput(crossProductList));
  }

  final left = stackInvertForRotation(p);
  final right = stackInvertForRotation(pPrime);

  final rotationMatrix =
      (left.inverse() * right).map((x) => x.round().toDouble());

  final translationVector = (pPrime[0] -
      Vector.fromMatrix((Matrix(toMatrixInput([p[0]])) * rotationMatrix))
          .map((x) => x.round().toDouble()));

  final tVList = translationVector.toList();

  /// Stack em all together now, 4x4 matrix time!
  final finalMatrixRows = [
    [...rotationMatrix.rowVector(0).toList(), tVList[0]],
    [...rotationMatrix.rowVector(1).toList(), tVList[1]],
    [...rotationMatrix.rowVector(2).toList(), tVList[2]],
    [0.0, 0.0, 0.0, 1.0]
  ];
  final finalMatrix = Matrix(finalMatrixRows);
  assert(finalMatrix.m == 4);
  assert(finalMatrix.n == 4);
  return finalMatrix;
}

Coord3D transformationMatrixOffset(Matrix transformationMatrix) {
  final translationNums = transformationMatrix.columnVector(3).toList();
  return Coord3D(translationNums[0].toInt(), translationNums[1].toInt(),
      translationNums[2].toInt());
}

void main() async {
  final input = await parseInput('19/demo');

  int count = 0;

  final matches = Map<Coord3D, Coord3D>();
  matches[Coord3D(-618, -824, -621)] = Coord3D(686, 422, 578);
  matches[Coord3D(-537, -823, -458)] = Coord3D(605, 423, 415);
  matches[Coord3D(-447, -329, 318)] = Coord3D(515, 917, -361);

  // final matches =
  checkForMatches(input[0].yDisplacements, input[1].yDisplacements)!;
  // final matchEntries = matches.entries.toList();

  // final matches = Map<Coord3D, Coord3D>();
  // matches[Coord3D(0, 2, 0)] = Coord3D(-5, 0, 0);
  // matches[Coord3D(4, 1, 0)] = Coord3D(-1, -1, 0);
  // matches[Coord3D(3, 3, 0)] = Coord3D(-2, 1, 0);

  determineTransformationMatrix(matches);

  // final matrixA = Matrix([
  //   matchEntries[0].key.toVector().toList(),
  //   matchEntries[1].key.toVector().toList(),
  //   matchEntries[2].key.toVector().toList()
  // ]);
  // final matrixB = Matrix([
  //   matchEntries[0].value.toVector().toList(),
  //   matchEntries[1].value.toVector().toList(),
  //   matchEntries[2].value.toVector().toList()
  // ]);

// --- scanner 0 ---
// 0,2
// 4,1
// 3,3

// --- scanner 1 ---
// -1,-1
// -5,0
// -2,1

// final coordsA = [Vec]

  // final transformationMatrix = matrixA.inverse() * matrixB;
  // print(transformationMatrix);

  // print(transformationMatrix * matrixB);

  // print(matrixA);
  // print(matrixB);

  // input[0].beacons.sort((a, b) => a.x.compareTo(b.x));
  // print(input[0].xDisplacements);
  // input[0].xDisplacements.forEach((xDisplacement) {
  //   if (input[1].xDisplacements.contains(xDisplacement)) {
  //     print(xDisplacement);
  //   }
  // });

  print(count);
}
