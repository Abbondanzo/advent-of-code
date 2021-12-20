import '../utils.dart';

class Input {
  final String enhancementAlgorithm;
  final List<List<String>> startInput;

  Input(this.enhancementAlgorithm, this.startInput);

  bool isLight(int index) {
    return enhancementAlgorithm[index] == '#';
  }
}

Future<Input> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();

  final enhancementAlgorithm = lines[0];
  assert(enhancementAlgorithm.length == 512);

  final imageInput = lines.sublist(2).map((line) => line.split('')).toList();
  return Input(enhancementAlgorithm, imageInput);
}
