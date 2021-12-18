import 'dart:convert';

import '../utils.dart';

Future<List<IntPair>> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();

  IntPair parseNums(dynamic input) {
    if (input is List<dynamic>) {
      assert(input.length == 2);
      final left = input[0] is int ? input[0] : parseNums(input[0]);
      final right = input[1] is int ? input[1] : parseNums(input[1]);
      return IntPair(left, right);
    } else {
      throw Error();
    }
  }

  return lines.map((line) {
    return parseNums(jsonDecode(line));
  }).toList();
}

class IntPair extends Pair<dynamic, dynamic> {
  IntPair(first, second) : super(first, second);
}

abstract class Result extends Pair<IntPair?, IntPair?> {
  Result(IntPair? first, IntPair? second) : super(first, second);
}

class KeepResult extends Result {
  KeepResult(IntPair? first, IntPair? second) : super(first, second);
}

class ExplodeResult extends Result {
  ExplodeResult(IntPair? first, IntPair? second) : super(first, second);
}

class SplitResult extends Result {
  SplitResult(IntPair? first, IntPair? second) : super(first, second);
}

Result? reduceHelper(IntPair pair, int depth) {
  print('$pair $depth');
  if (depth >= 4) {
    assert(pair.first is int);
    assert(pair.second is int);
    return ExplodeResult(pair.first, pair.second);
  }

  SplitResult? checkSplit(int item) {
    if (item >= 10) {
      return SplitResult((item / 2).floor(), (item / 2).ceil());
    }
  }

  final maybeLeftResult = pair.first is int
      ? checkSplit(pair.first)
      : reduceHelper(pair.first, depth + 1);

  if (maybeLeftResult != null) {
    return maybeLeftResult;
  }

  final maybeRightResult = pair.second is int
      ? checkSplit(pair.second)
      : reduceHelper(pair.second, depth + 1);
  if (maybeRightResult != null) {
    if (maybeRightResult is ExplodeResult) {
      return ExplodeResult(first, )
    }
    return maybeRightResult;
  }

  return KeepResult(pair.first, pair.second);
}

void main() async {
  final input = await parseInput('18/demo');
  print(reduceHelper(input[0], 0));
}
