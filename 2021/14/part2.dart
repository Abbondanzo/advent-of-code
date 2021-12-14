import 'dart:collection';

import '../utils.dart';
import './part1.dart';

// extension FirstWhereOrNullExtension<E> on Iterable<E> {
//   E? firstWhereOrNull(bool Function(E) test) {
//     for (E element in this) {
//       if (test(element)) return element;
//     }
//     return null;
//   }
// }

// final additionalInsertionRules = SplayTreeMap<String, String>();

final Map<String, String> savedPolymers = Map();

String expandPolymer(Input input, String startPolymer) {
  if (savedPolymers[startPolymer] != null) {
    return savedPolymers[startPolymer]!;
  }
  if (startPolymer.length == 1) {
    return startPolymer;
  }
  if (startPolymer.length == 2) {
    return startPolymer[0] +
        input.insertionRules[startPolymer]! +
        startPolymer[1];
  }
  final middleIndex = startPolymer.length ~/ 2;
  final leftSide = startPolymer.substring(0, middleIndex);
  final rightSide = startPolymer.substring(middleIndex);
  final middle = leftSide[leftSide.length - 1] + rightSide[0];

  final combinedResult = expandPolymer(input, leftSide) +
      input.insertionRules[middle]! +
      expandPolymer(input, rightSide);
  savedPolymers[startPolymer] = combinedResult;
  return combinedResult;
}

extension Part2 on Input {
  Map<String, BigInt> runStepsV2(int numSteps) {
    final bigramCounts = Map<String, BigInt>();
    final letterCounts = Map<String, BigInt>();

    /// Set initial counts
    for (int i = 0; i < this.polyTemplate.length - 1; i++) {
      final bigram = this.polyTemplate.substring(i, i + 2);
      bigramCounts.update(bigram, (value) => value + BigInt.one,
          ifAbsent: () => BigInt.one);
    }
    for (int i = 0; i < this.polyTemplate.length; i++) {
      letterCounts.update(this.polyTemplate[i], (value) => value + BigInt.one,
          ifAbsent: () => BigInt.one);
    }

    List.generate(numSteps, (index) {
      bigramCounts.entries.toList().forEach((entry) {
        final insertionChar = this.insertionRules[entry.key]!;
        final left = entry.key[0] + insertionChar;
        final right = insertionChar + entry.key[1];
        bigramCounts.update(entry.key, (value) => value - entry.value);
        bigramCounts.update(left, (value) => value + entry.value,
            ifAbsent: () => entry.value);
        bigramCounts.update(right, (value) => value + entry.value,
            ifAbsent: () => entry.value);
        letterCounts.update(insertionChar, (value) => value + entry.value,
            ifAbsent: () => entry.value);
      });
    });

    return letterCounts;
  }
}

void main() async {
  final input = await parseInput('14/input');

  final letterCounts = input.runStepsV2(40);
  BigInt? lowest;
  BigInt? highest;
  letterCounts.values.forEach((value) {
    if (lowest == null || value < lowest!) {
      lowest = value;
    }
    if (highest == null || value > highest!) {
      highest = value;
    }
  });

  print(highest! - lowest!);
}
