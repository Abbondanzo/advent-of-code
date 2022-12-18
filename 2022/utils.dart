import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:equatable/equatable.dart';

Stream<String> readFile(String fileName) {
  final file = File(fileName);
  Stream<String> lines = file
      .openRead()
      .transform(utf8.decoder) // Decode bytes to UTF-8.
      .transform(LineSplitter());
  return lines;
}

int flipBits(int n, int k) {
  int mask = (1 << k) - 1;
  return ~n & mask;
}

int median(List<int> input) {
  return input[input.length ~/ 2];
}

int mean(List<int> input) {
  int total =
      input.fold(0, (previousValue, element) => previousValue + element);
  return total ~/ input.length;
}

class Coordinate extends Equatable {
  final int x;
  final int y;

  Coordinate(this.x, this.y);

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() {
    return '($x, $y)';
  }
}

class Pair<A, B> extends Equatable {
  final A first;
  final B second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return 'Pair($first, $second)';
  }

  @override
  List<Object?> get props => [first, second];
}

/// Generate a list of numbers for iterative purposes.
///
/// If `end` is not specified, the range starts at 0 and contains `count`
/// elements.
///
/// ```dart
/// range(3); // [0, 1, 2]
/// ```
///
/// If `end` is specified, the range starts at `count` and ends at one value
/// less than `end`.
///
/// ```dart
/// range(1, 5); // [1, 2, 3, 4]
/// ```
List<int> range(int count, [int? end = null]) {
  if (end != null) {
    final start = count;
    return List.generate(end - start, (index) => start + index);
  }
  return List.generate(count, (index) => index);
}

class ErrorMessage extends Error {
  final String message;

  ErrorMessage(this.message);
}
