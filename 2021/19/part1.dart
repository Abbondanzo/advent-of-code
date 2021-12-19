import 'package:equatable/equatable.dart';

import './parse.dart';

void main() async {
  final input = await parseInput('19/demo');

  print(input[0].xDisplacements.intersection(input[1].xDisplacements).length);
}
