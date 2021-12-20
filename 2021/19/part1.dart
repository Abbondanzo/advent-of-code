import 'dart:collection';

import './parse.dart';
import '../utils.dart';

extension ListIntersect<E> on List<E> {
  List<E> intersection(List<E> other) {
    return this.where((element) => other.contains(element)).toList();
  }
}

bool checkMapsForMatches(
    DisplacementMap displacementMapA, DisplacementMap displacementMapB) {
  int matchCount = 0;
  for (var displacementEntry in displacementMapA.entries) {
    for (var otherDisplacementEntry in displacementMapB.entries) {
      if (displacementEntry.value
              .intersection(otherDisplacementEntry.value)
              .length >=
          12) {
        matchCount++;
        if (matchCount >= 12) {
          return true;
        }
      }
    }
  }
  return false;
}

class TransformerPair extends Pair<String, int> {
  TransformerPair(String first, int second) : super(first, second);
}

Coord3D Function(Coord3D)? checkScannerTransformer(
    Scanner fromScanner, Scanner toScanner) {
  final hasDisplacementOverlap = checkMapsForMatches(
          fromScanner.xDisplacements, toScanner.xDisplacements) ||
      checkMapsForMatches(
          fromScanner.xDisplacements, toScanner.yDisplacements) ||
      checkMapsForMatches(fromScanner.xDisplacements, toScanner.zDisplacements);

  if (hasDisplacementOverlap) {
    TransformerPair Function(Coord3D fromScannerCoord) xTransformer;
    TransformerPair Function(Coord3D fromScannerCoord) yTransformer;
    TransformerPair Function(Coord3D fromScannerCoord) zTransformer;

    if (checkMapsForMatches(
        fromScanner.xDisplacements, toScanner.xDisplacements)) {
      xTransformer =
          checkMapsForMatches(fromScanner.xDistances, toScanner.xDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('x', fromScannerCoord.x)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('x', -fromScannerCoord.x);
    } else if (checkMapsForMatches(
        fromScanner.xDisplacements, toScanner.yDisplacements)) {
      xTransformer =
          checkMapsForMatches(fromScanner.xDistances, toScanner.yDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('y', fromScannerCoord.x)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('y', -fromScannerCoord.x);
    } else {
      xTransformer =
          checkMapsForMatches(fromScanner.xDistances, toScanner.zDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('z', fromScannerCoord.x)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('z', -fromScannerCoord.x);
    }

    if (checkMapsForMatches(
        fromScanner.yDisplacements, toScanner.xDisplacements)) {
      yTransformer =
          checkMapsForMatches(fromScanner.yDistances, toScanner.xDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('x', fromScannerCoord.y)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('x', -fromScannerCoord.y);
    } else if (checkMapsForMatches(
        fromScanner.yDisplacements, toScanner.yDisplacements)) {
      yTransformer =
          checkMapsForMatches(fromScanner.yDistances, toScanner.yDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('y', fromScannerCoord.y)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('y', -fromScannerCoord.y);
    } else {
      yTransformer =
          checkMapsForMatches(fromScanner.yDistances, toScanner.zDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('z', fromScannerCoord.y)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('z', -fromScannerCoord.y);
    }

    if (checkMapsForMatches(
        fromScanner.zDisplacements, toScanner.xDisplacements)) {
      zTransformer =
          checkMapsForMatches(fromScanner.zDistances, toScanner.xDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('x', fromScannerCoord.z)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('x', -fromScannerCoord.z);
    } else if (checkMapsForMatches(
        fromScanner.zDisplacements, toScanner.yDisplacements)) {
      zTransformer =
          checkMapsForMatches(fromScanner.zDistances, toScanner.yDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('y', fromScannerCoord.z)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('y', -fromScannerCoord.z);
    } else {
      zTransformer =
          checkMapsForMatches(fromScanner.zDistances, toScanner.zDistances)
              ? (Coord3D fromScannerCoord) =>
                  TransformerPair('z', fromScannerCoord.z)
              : (Coord3D fromScannerCoord) =>
                  TransformerPair('z', -fromScannerCoord.z);
    }

    return (Coord3D fromScannerCoord) {
      final Map<String, int> map = Map();
      final xResult = xTransformer(fromScannerCoord);
      map[xResult.first] = xResult.second;
      final yResult = yTransformer(fromScannerCoord);
      map[yResult.first] = yResult.second;
      final zResult = zTransformer(fromScannerCoord);
      map[zResult.first] = zResult.second;
      return Coord3D(map['x']!, map['y']!, map['z']!);
    };
  }
}

List<OutputScanner> assembleScanners(Input input) {
  final scanners = input.asMap().entries.toList();
  final firstScanner = scanners.first;
  final availableScanners = [...scanners];
  availableScanners.remove(firstScanner);
  final Map<int, Coord3D> translations =
      Map.fromEntries([MapEntry(0, Coord3D(0, 0, 0))]);
  final Map<int, Scanner> transformedScanners = Map();
  final scannerQueue = Queue<MapEntry<int, Scanner>>.from([firstScanner]);
  while (scannerQueue.isNotEmpty) {
    final currentScanner = scannerQueue.removeFirst();
    transformedScanners[currentScanner.key] = currentScanner.value;
    final currentTransformation = translations[currentScanner.key]!;

    while (true) {
      Coord3D Function(Coord3D)? transformer = null;
      final nextScanner = availableScanners.firstWhere((maybeNextScanner) {
        final maybeTransformer = checkScannerTransformer(
            maybeNextScanner.value, currentScanner.value);
        transformer = maybeTransformer;
        return maybeTransformer != null;
      }, orElse: () => MapEntry(-1, Scanner([])));

      if (transformer == null) {
        break;
      }

      MapEntry<Coord3D, Coord3D> getFirstCoordMatch(
          DisplacementMap displacementMapA, DisplacementMap displacementMapB) {
        Map<Coord3D, Coord3D> matches = Map();

        for (var displacementEntry in displacementMapA.entries) {
          for (var otherDisplacementEntry in displacementMapB.entries) {
            if (displacementEntry.value
                    .intersection(otherDisplacementEntry.value)
                    .length >=
                12) {
              matches[displacementEntry.key] = otherDisplacementEntry.key;
            }
          }
        }

        return matches.entries.toList()[2];
      }

      availableScanners.remove(nextScanner);

      final intermediateBeacons =
          nextScanner.value.beacons.map(transformer!).toList();

      final intermediateScanner = Scanner(intermediateBeacons);

      final entryMatch = getFirstCoordMatch(intermediateScanner.xDisplacements,
          currentScanner.value.xDisplacements);
      final transformation =
          entryMatch.value - entryMatch.key + currentTransformation;

      translations[nextScanner.key] = transformation;

      scannerQueue.addLast(MapEntry(nextScanner.key, intermediateScanner));
    }
  }

  // List<Map<String, dynamic>> json = [];
  // transformedScanners.entries.forEach((scanner) {
  //   final Map<String, dynamic> map = Map();
  //   map['position'] = translations[scanner.key]!.toJSON();
  //   map['beacons'] =
  //       scanner.value.beacons.map((beacon) => beacon.toJSON()).toList();
  //   json.add(map);
  // });
  // print(jsonEncode(json));

  List<OutputScanner> outputScanners = [];
  transformedScanners.entries.forEach((scanner) {
    outputScanners
        .add(OutputScanner(translations[scanner.key]!, scanner.value.beacons));
  });
  return outputScanners;
}

void main() async {
  final input = await parseInput('19/input');
  final scanners = assembleScanners(input);

  final Set<Coord3D> allBeacons = Set();
  scanners.forEach((scanner) {
    final normalizedBeacons =
        scanner.beacons.map((beacon) => beacon + scanner.position);
    allBeacons.addAll(normalizedBeacons);
  });

  print(allBeacons.length);
}
