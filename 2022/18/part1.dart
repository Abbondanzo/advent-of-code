import './shared.dart';
import '../utils.dart';

void main() async {
  final input = await parseInput('18/input');
  print(exteriorSides(input));
}
