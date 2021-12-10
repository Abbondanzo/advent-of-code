import 'dart:collection';

import '../utils.dart';

Future<List<List<String>>> parseInput() async {
  final inputLines = readFile('10/input');
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) => line.split('')).toList();
}

final Map<String, String> CHUNK_MAP = {'(': ')', '<': '>', '[': ']', '{': '}'};

class ChunkError extends Error {
  final String expected;
  final String found;

  ChunkError(this.expected, this.found);
}

void processLine(List<String> characters) {
  final chunkQueue = Queue<String>();

  characters.forEach((element) {
    // Closes a chunk
    if (CHUNK_MAP.values.contains(element)) {
      final chunkStart = chunkQueue.removeLast();
      if (CHUNK_MAP[chunkStart] != element) {
        throw ChunkError(CHUNK_MAP[chunkStart]!, element);
      }
    }
    // Starts a new chunk
    else {
      chunkQueue.addLast(element);
    }
  });
}

int illegalCharacterWorth(String character) {
  switch (character) {
    case ')':
      return 3;
    case ']':
      return 57;
    case '}':
      return 1197;
    case '>':
      return 25137;
    default:
      return 0;
  }
}

void main() async {
  final inputLines = await parseInput();

  int total = 0;
  inputLines.forEach((line) {
    try {
      processLine(line);
    } catch (error) {
      if (error is ChunkError) {
        total += illegalCharacterWorth(error.found);
      } else {
        throw error;
      }
    }
  });

  print(total);
}
