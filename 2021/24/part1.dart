import 'dart:collection';

import './parse.dart';

class QueuedBit {
  final int c;
  final int digitIdx;

  QueuedBit(this.c, this.digitIdx);

  @override
  String toString() {
    return 'QB($c, idx:$digitIdx)';
  }
}

void main() async {
  final input = await parseInput('24/input');

  final List<int> output = List.filled(14, 9);
  final bitQueue = Queue<QueuedBit>();

  input.aList.asMap().entries.forEach((entry) {
    final a = entry.value;
    assert(a == 1 || a == 26);
    final addBit = a == 1;

    final outputIdx = entry.key;
    final b = input.bList[outputIdx];
    assert(addBit ? b >= 10 : b < 0);

    final c = input.cList[outputIdx];

    if (addBit) {
      bitQueue.addLast(QueuedBit(c, outputIdx));
    } else {
      final lastBit = bitQueue.removeLast();
      final leastSignificantBit = (lastBit.c + b) % 26;
      final addsToZReg = leastSignificantBit > 9 ? 9 : 9 - leastSignificantBit;
      final removesFromZReg = addsToZReg + lastBit.c + b;
      output[lastBit.digitIdx] = addsToZReg;
      output[outputIdx] = removesFromZReg;
    }
  });

  print(output.join(''));
}
