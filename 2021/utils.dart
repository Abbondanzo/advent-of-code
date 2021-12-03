import 'dart:io';
import 'dart:convert';
import 'dart:async';

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
