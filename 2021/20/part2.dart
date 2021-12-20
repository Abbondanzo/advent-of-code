import './parse.dart';
import './part1.dart';

void main() async {
  final input = await parseInput('20/input');
  final image = runTimes(input, 50);
  print(image.countLit());
}
