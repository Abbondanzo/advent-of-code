import './part1.dart';

///
/// Let positions on a seven-segment display be positioned in as keys as
/// follows:
///
///```
///  0000
/// 1    2
/// 1    2
///  3333
/// 4    5
/// 4    5
///  6666
///```
///
bool setEquals<T>(Set<T>? a, Set<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (final T value in a) {
    if (!b.contains(value)) return false;
  }
  return true;
}

Set<String> getWires() => ['a', 'b', 'c', 'd', 'e', 'f', 'g'].toSet();

Map<int, Set<String>> generatePositionsPossibilities() {
  final entries = List.generate(7, (index) => MapEntry(index, getWires()));
  return Map.fromEntries(entries);
}

// List<String> getCharsInAssumedPosition(
//     Map<String, List<int>> pp, int position) {
//   final validEntries = pp.entries.where((element) {
//     return element.value.contains(position);
//   }).toList();
//   validEntries.sort((a, b) => a.value.length.compareTo(b.value.length));
//   int lowestLength = 8;
//   validEntries.forEach((element) {
//     if (element.value.length < lowestLength) {
//       lowestLength = element.value.length;
//     }
//   });
//   return validEntries
//       .where((element) => element.value.length == lowestLength)
//       .toList()
//       .map((e) => e.key)
//       .toList();
// }

Map<int, Set<String>> determinePositionsFromDigits(List<String> digits) {
  // Sort digits from shortest length to greatest
  digits.sort((a, b) => a.length.compareTo(b.length));
  // Assign the uniques
  final digitOne = digits[0].split('').toSet();
  assert(digitOne.length == 2); // 1 (l=2)
  final digitSeven = digits[1].split('').toSet();
  assert(digitSeven.length == 3); // 7 (l=3)
  final digitFour = digits[2].split('').toSet();
  assert(digitFour.length == 4); // 4 (l=4)
  final digitEight = digits[9].split('').toSet();
  assert(digitEight.length == 7); // 8 (l=7)
  // Position possibilities
  final pp = generatePositionsPossibilities();
  // Get topChar
  final topCharSet = digitSeven.difference(digitOne);
  assert(topCharSet.length == 1);
  pp[0] = topCharSet;
  // Set two rightChars
  pp[2] = digitOne;
  pp[5] = digitOne;
  // Set positions 1 and 3
  final topSidesSet = digitFour.difference(digitOne);
  assert(topSidesSet.length == 2);
  pp[1] = topSidesSet;
  pp[3] = topSidesSet;

  // Dealing with unknowns
  final unknowns = digits.sublist(3, 9).map((unknown) {
    return unknown.split('').toSet();
  }).toList();

  // Compute bottom-left of 6 by union of 1 to 8
  final digitSix = unknowns.firstWhere((unknown) {
    return setEquals(unknown.union(digitOne), digitEight) &&
        setEquals(digitOne, digitOne.union(digitEight.difference(unknown)));
  });
  unknowns.remove(digitSix);
  final topRightCharSet = digitEight.difference(digitSix);
  assert(topRightCharSet.length == 1);
  final bottomRightCharSet = pp[5]!.difference(topRightCharSet);
  assert(bottomRightCharSet.length == 1);
  pp[2] = topRightCharSet;
  pp[5] = bottomRightCharSet;

  // Now that 6 is removed from unknowns, 5 is the only remaining that can be
  // impacted by a union with top-right
  final digitFive = unknowns.firstWhere((unknown) {
    return !setEquals(unknown.union(topRightCharSet), unknown);
  });
  unknowns.remove(digitFive);
  final bottomLeftCharSet =
      digitEight.difference(digitFive.union(topRightCharSet));
  assert(bottomLeftCharSet.length == 1);
  pp[4] = bottomLeftCharSet;

  // 2 is the only remaining that can be impacted by a union with bottom-right
  final digitTwo = unknowns.firstWhere((unknown) {
    return !setEquals(unknown.union(bottomRightCharSet), unknown);
  });
  unknowns.remove(digitTwo);
  final topLeftCharSet =
      digitEight.difference(digitTwo.union(bottomRightCharSet));
  assert(topLeftCharSet.length == 1);
  pp[1] = topLeftCharSet;
  final middleCharSet = pp[3]!.difference(topLeftCharSet);
  assert(middleCharSet.length == 1);
  pp[3] = middleCharSet;

  // Set bottom
  final allButBottom = digitFour.union(topCharSet).union(bottomLeftCharSet);
  final bottomCharSet = digitEight.difference(allButBottom);
  assert(bottomCharSet.length == 1);
  pp[6] = bottomCharSet;

  //
  final digitZero = digitEight.difference(middleCharSet);
  final digitNine = digitEight.difference(bottomLeftCharSet);
  final digitThree = digitNine.difference(topLeftCharSet);

  return {
    0: digitZero,
    1: digitOne,
    2: digitTwo,
    3: digitThree,
    4: digitFour,
    5: digitFive,
    6: digitSix,
    7: digitSeven,
    8: digitEight,
    9: digitNine
  };
}

int determineCodeFromInputLine(InputLine line) {
  final positions = determinePositionsFromDigits(line.digits);
  final codeStringParsed = line.code.map((codeDigit) {
    final codeDigitSet = codeDigit.split('').toSet();
    final digit = positions.entries
        .firstWhere((element) => setEquals(element.value, codeDigitSet))
        .key;
    return '$digit';
  }).join('');
  return int.parse(codeStringParsed);
}

// dart run --enable-asserts 8/part2.dart
void main() async {
  final inputLines = await parseInput();

  final int total = inputLines.fold(0, (previous, inputLine) {
    return previous + determineCodeFromInputLine(inputLine);
  });

  // What do you get if you add up all of the output values?
  print(total);
}
