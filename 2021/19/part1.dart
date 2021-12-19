import 'package:equatable/equatable.dart';

import './parse.dart';

void main() async {
  final input = await parseInput('19/demo');
  print(input);
}
