import './part1.dart';

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
