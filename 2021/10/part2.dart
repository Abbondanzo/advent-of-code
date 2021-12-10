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

List<String> completeLine(List<String> line) {
  final chunkQueue = Queue<String>();

  line.forEach((element) {
    /// Closes a chunk
    if (CHUNK_MAP.values.contains(element)) {
      final chunkStart = chunkQueue.removeLast();
      if (CHUNK_MAP[chunkStart] != element) {
        throw ChunkError(CHUNK_MAP[chunkStart]!, element);
      }
    }

    /// Starts a new chunk
    else {
      chunkQueue.addLast(element);
    }
  });

  List<String> closers = [];
  while (chunkQueue.isNotEmpty) {
    final chunkStart = chunkQueue.removeLast();
    closers.add(CHUNK_MAP[chunkStart]!);
  }
  return closers;
}

int legalCharacterWorth(String character) {
  switch (character) {
    case ')':
      return 1;
    case ']':
      return 2;
    case '}':
      return 3;
    case '>':
      return 4;
    default:
      return 0;
  }
}

void main() async {
  final inputLines = await parseInput();

  List<int> lineCompletionTotals = [];

  inputLines.forEach((line) {
    try {
      int lineTotal = 0;
      final closers = completeLine(line);
      closers.forEach((closer) {
        lineTotal *= 5;
        lineTotal += legalCharacterWorth(closer);
      });
      lineCompletionTotals.add(lineTotal);
    } catch (error) {
      if (error is ChunkError) {
        /// Do nothing
      } else {
        throw error;
      }
    }
  });

  /// Sort ascending
  lineCompletionTotals.sort((a, b) => a.compareTo(b));

  /// Grab middle score
  final middleIndex = (lineCompletionTotals.length / 2).floor();
  print(lineCompletionTotals[middleIndex]);
}
