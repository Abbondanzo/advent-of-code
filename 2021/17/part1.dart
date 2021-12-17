import '../utils.dart';

Future<void> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();
}

void main() async {
  parseInput('17/demo');
}
