import '../utils.dart';

List<String> filterToLastItem(List<String> lines, int index, bool msb) {
  if (lines.length <= 1) {
    return lines;
  }

  final zeros = <String>[];
  final ones = <String>[];
  lines.forEach((line) {
    if (line[index] == '1') {
      ones.add(line);
    } else {
      zeros.add(line);
    }
  });

  if (msb) {
    if (zeros.length - 1 < ones.length) {
      return ones;
    } else {
      return zeros;
    }
  } else {
    if (zeros.length > ones.length) {
      return ones;
    } else {
      return zeros;
    }
  }
}

String filterRating(List<String> lines, bool msb) {
  assert(lines.length >= 1);

  var lineList = lines;
  Iterable<int>.generate(lines[0].length).forEach((index) {
    lineList = filterToLastItem(lineList, index, msb);
  });

  return lineList[0];
}

void main() async {
  final lines = readFile('3/input');
  final lineList = await lines.toList();

  // Oxygen generator rating
  final o2List = filterRating(lineList, true);
  // CO2 scrubber rating
  final co2List = filterRating(lineList, false);

  assert(o2List.length == 1);
  assert(co2List.length == 1);

  final o2Rating = int.parse(o2List, radix: 2);
  final co2Rating = int.parse(co2List, radix: 2);

  // // What is the life support rating of the submarine?
  print('The life support rating is ${o2Rating * co2Rating}');
}
