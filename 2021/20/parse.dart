import '../utils.dart';

typedef Image = List<List<String>>;

class Input {
  final String enhancementAlgorithm;
  final Image imageInput;

  Input(this.enhancementAlgorithm, this.imageInput);

  bool isEnhancementLight(int index) {
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

// class Image {
//   final List<List<String>> _data;

//   Image(this._data);

//   Image copy() {
//     final copiedData = List<List<String>>.from(
//         _data.map((row) => List<String>.from(row).toList())).toList();
//     return Image(copiedData);
//   }
// }
