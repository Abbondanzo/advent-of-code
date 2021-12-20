import 'package:linalg/linalg.dart';

import './parse.dart';

Matrix identityMatrix() {
  final rows = List.generate(4, (index) {
    final row = List.filled(4, 0.0);
    row[index] = 1.0;
    return row;
  });
  return Matrix(rows);
}

Coord3D applyTransformationMatrix(Matrix transformationMatrix, Coord3D coord) {
  final matrixToMult =
      Vector.column([...coord.toVector().toList(), 1.0]).toMatrix();
  final result = transformationMatrix * matrixToMult;
  final vectorNums = result.columnVector(0).toList();
  print(vectorNums);
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
