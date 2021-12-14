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
  String runStepsV2(int numSteps) {
    String toModify = this.polyTemplate;
    List.generate(numSteps, (index) {
      print('Step ${index + 1}/$numSteps (len ${toModify.length})');
      toModify = expandPolymer(this, toModify);
    });
    return toModify;
  }
}

// String runStep(Input input, String curString) {
//   List<String> foo = ['N', 'N', 'N', 'C', 'C', 'B'];
//   foo.s

//   String output = '';
//   while (output.length < curString.length * 2 - 1) {
//     final remaining = curString.substring(output.length);
//     final hasRule = additionalInsertionRules.entries.firstWhereOrNull((element) => curString.startsWith(element.key));
//     if (hasRule != null) {
//       output += additionalInsertionRules[hasRule.key]!;
//     } else {
//       output += input.insertionRules[]
//     }
//   }
//   if (hasRule) {

//   }
//   if (curString.st)
// }

void main() async {
  final input = await parseInput('14/demo');

  final outputStr = input.runStepsV2(40);
  // final nextOutput = expandPolymer(input, outputStr);

  // print(nextOutput.length);
  // print(input.runSteps(11).length);

  // if (outputStr != input.runSteps(11)) {
  //   throw new Error('Fuck');
  // }

  // final output = mostCommonMinusLeastCommon(outputStr);
  // print(output);
}
