import '../utils.dart';

Future<void> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();
}

void main() async {
  final input = parseInput('16/demo');
}
