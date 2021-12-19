import 'package:equatable/equatable.dart';

import './parse.dart';

void main() async {
  final input = await parseInput('19/demo');

  int count = 0;
  input[0].xDisplacements.forEach(print);
  // input[0].beacons.sort((a, b) => a.x.compareTo(b.x));
  // print(input[0].xDisplacements);
  // input[0].xDisplacements.forEach((xDisplacement) {
  //   if (input[1].xDisplacements.contains(xDisplacement)) {
  //     print(xDisplacement);
  //   }
  // });

  print(count);
}
