import '../utils.dart';

void main() async {
  final lines = readFile('5/input');
  final lineList = await lines.toList();
  print(lineList);
}
