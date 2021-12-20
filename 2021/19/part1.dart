import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:linalg/linalg.dart';

import './parse.dart';
import './matrix.dart';

extension ListIntersect<E> on List<E> {
  List<E> intersection(List<E> other) {
    return this.where((element) => other.contains(element)).toList();
  }
}

Map<Coord3D, Coord3D>? checkDisplacementsForMatches(
    DisplacementMap displacementMapA, DisplacementMap displacementMapB) {
  Map<Coord3D, Coord3D> matches = Map();

  displacementMapA.entries.forEach((displacementEntry) {
    for (var otherDisplacementEntry in displacementMapB.entries) {
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

Map<Coord3D, Coord3D>? checkForMatches(Scanner scannerA, Scanner scannerB) {
  return checkDisplacementsForMatches(
      scannerA.xDisplacements, scannerB.xDisplacements);
}

void assembleBeacons(Input input) {
  final scanners = input.asMap().entries.toList();

  final firstScanner = scanners.first;
  final availableScanners = [...scanners];
  availableScanners.remove(firstScanner);
  final Map<int, Matrix> transformationMatrices =
      Map.fromEntries([MapEntry(0, identityMatrix())]);

  final scannerQueue = Queue<MapEntry<int, Scanner>>.from([firstScanner]);
  while (scannerQueue.isNotEmpty) {
    final currentScanner = scannerQueue.removeFirst();
    final currentTransformationMatrix =
        transformationMatrices[currentScanner.key]!;

    while (true) {
      Map<Coord3D, Coord3D>? matches = null;
      final nextScanner = availableScanners.firstWhere((maybeNextScanner) {
        final maybeMatches =
            checkForMatches(currentScanner.value, maybeNextScanner.value);
        matches = maybeMatches;
        return maybeMatches != null;
      }, orElse: () => MapEntry(-1, Scanner([])));

      if (matches == null) {
        break;
      }

      scannerQueue.addLast(nextScanner);
      availableScanners.remove(nextScanner);

      final intermediateTMatrix =
          determineTransformationMatrix(matches!).inverse();
      print('Cur ${currentScanner.key} next ${nextScanner.key}');
      print(intermediateTMatrix);
      print(intermediateTMatrix.inverse());
      print(intermediateTMatrix.inverse().inverse());

      print(currentTransformationMatrix *
          intermediateTMatrix *
          currentTransformationMatrix.inverse());
      print(currentTransformationMatrix *
          intermediateTMatrix.inverse() *
          currentTransformationMatrix.inverse());

      print(intermediateTMatrix *
          currentTransformationMatrix *
          intermediateTMatrix.inverse());
      print(intermediateTMatrix.inverse() *
          currentTransformationMatrix *
          intermediateTMatrix);

      transformationMatrices[nextScanner.key] = intermediateTMatrix;
    }
  }
  // Scanner curScanner =

  // transformationMatrices.entries.forEach(print);

  // Coord3D starter = Coord3D(0, 0, 0);
  // transformationMatrices[4]!.forEach(print);
  // transformationMatrices[4]!.forEach((element) {
  //   starter = applyTransformationMatrix(element, starter);
  // });
  // print(starter);

  print(transformationMatrices);

  // Coord3D starter = Coord3D(0, 0, 0);
  // starter = applyTransformationMatrix(transformationMatrices[1]!, starter);
  // print(starter);
  // starter = applyTransformationMatrix(transformationMatrices[4]!, starter);
  // print(starter);
}

void main() async {
  final input = await parseInput('19/demo');
  assembleBeacons(input);

  // final matches = Map<Coord3D, Coord3D>();
  // matches[Coord3D(-618, -824, -621)] = Coord3D(686, 422, 578);
  // matches[Coord3D(-537, -823, -458)] = Coord3D(605, 423, 415);
  // matches[Coord3D(-447, -329, 318)] = Coord3D(515, 917, -361);

  // final matches =
  // checkForMatches(input[0].yDisplacements, input[1].yDisplacements)!;
  // final matchEntries = matches.entries.toList();

  // final matches = Map<Coord3D, Coord3D>();
  // matches[Coord3D(0, 2, 0)] = Coord3D(-5, 0, 0);
  // matches[Coord3D(4, 1, 0)] = Coord3D(-1, -1, 0);
  // matches[Coord3D(3, 3, 0)] = Coord3D(-2, 1, 0);

  // determineTransformationMatrix(matches);

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

  // print(count);
}
