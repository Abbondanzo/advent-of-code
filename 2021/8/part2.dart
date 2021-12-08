import './part1.dart';

///
/// Let positions on a seven-segment display be positioned in an array as
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

List<String> getWires() => ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

Map<String, List<int>> generatePositionsPossibilities() {
  return getWires().asMap().map((_, value) {
    return MapEntry(value, List.generate(7, (index) => index));
  });
}

List<String> getCharsInAssumedPosition(
    Map<String, List<int>> pp, int position) {
  final validEntries = pp.entries.where((element) {
    return element.value.contains(position);
  }).toList();
  validEntries.sort((a, b) => a.value.length.compareTo(b.value.length));
  int lowestLength = 8;
  validEntries.forEach((element) {
    if (element.value.length < lowestLength) {
      lowestLength = element.value.length;
    }
  });
  return validEntries
      .where((element) => element.value.length == lowestLength)
      .toList()
      .map((e) => e.key)
      .toList();
}

void determinePositionsFromDigits(List<String> digits) {
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
  pp[topCharSet.first] = [0];
  // Set two rightChars
  pp[digitOne.toList()[0]] = [2, 5];
  pp[digitOne.toList()[1]] = [2, 5];
  // Set positions 1 and 3
  final topSidesSet = digitFour.difference(digitOne);
  assert(topSidesSet.length == 2);
  pp[topSidesSet.first] = [1, 3];
  pp[topSidesSet.last] = [1, 3];

  // Dealing with unknowns
  final unknowns = digits.sublist(3, 8).map((unknown) {
    return unknown.split('').toSet();
  });

  // Compute position from 9 by union of 4 and 7 minus the bottom
  final almostNineUnion = digitFour.union(digitSeven);
  print(almostNineUnion);
  final digitNine = unknowns.firstWhere((unknown) {
    return unknown.difference(almostNineUnion).length == 1;
  });
  final bottomCharSet = digitNine.difference(almostNineUnion);
  assert(bottomCharSet.length == 1);
  pp[bottomCharSet.first] = [6];
  // Also use 9 to determine bottom-left
  final bottomLeftCharSet = getWires().toSet().difference(digitNine);
  print(digitNine);
  assert(bottomLeftCharSet.length == 1);
  pp[bottomLeftCharSet.first] = [4];

  // Compute top-left from seven, bottom, and bottom-left
  final almostZeroUnion =
      digitSeven.union(bottomLeftCharSet).union(bottomCharSet);
  final digitZero = unknowns.firstWhere((unknown) {
    return unknown.difference(almostZeroUnion).length == 1;
  });
  final topLeftCharSet = digitZero.difference(almostZeroUnion);
  assert(topLeftCharSet.length == 1);
  pp[topLeftCharSet.first] = [1];
  // Also use 0 to determine middle
  final middleCharSet = digitEight.difference(digitZero);
  assert(middleCharSet.length == 1);
  pp[middleCharSet.first] = [3];

  print(pp);
}

void main() async {
  final inputLines = await parseInput();

  determinePositionsFromDigits(inputLines[0].digits);

  // What do you get if you add up all of the output values?
  print(0);
}
