import '../utils.dart';

List<String> mostCommonBits(List<String> input) {
  var lineLength;
  var bitCounts;

  for (var line in input) {
    lineLength ??= line.length;
    bitCounts ??= new List.filled(lineLength, 0);

    line.split('').asMap().forEach((index, value) {
      if (value == '0') {
        bitCounts[index] -= 1;
      } else {
        bitCounts[index] += 1;
      }
    });
  }

  return bitCounts.map<String>((int count) {
    if (count > 0) {
      return '1';
    } else {
      return '0';
    }
  }).toList();
}

void main() async {
  final lines = readFile('3/input');
  final lineList = await lines.toList();
  final outputBinary = mostCommonBits(lineList).join('');

  var gamma = int.parse(outputBinary, radix: 2);
  var epsilon = flipBits(gamma, outputBinary.length);

  // What is the power consumption of the submarine?
  print('The power rate is ${gamma * epsilon}');
}
