import "../utils.dart";

class Input {
  final List<List<String>> tiles;
  final List<Pair<int, String>> instructions;

  Input(this.tiles, this.instructions);
}

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  final List<List<String>> tiles = [];
  bool isTiles = true;
  final List<Pair<int, String>> instructions = [];

  inputLineList.forEach((line) {
    if (line.trim() == "") {
      isTiles = false;
      return;
    }

    if (isTiles) {
      tiles.add(line.split(""));
    } else {
      final chars = line.split("");
      int idx = 0;
      String buffer = "";
      while (idx < chars.length) {
        final char = chars[idx];
        if (char == "R" || char == "L") {
          int number = int.parse(buffer);
          instructions.add(Pair(number, char));
          buffer = "";
        } else {
          buffer += char;
        }
        idx++;
      }
      if (buffer.length > 0) {
        int number = int.parse(buffer);
        instructions.add(Pair(number, ""));
      }
    }
  });

  return Input(tiles, instructions);
}
