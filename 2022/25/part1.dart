import 'dart:math';

import "./shared.dart";
import "../utils.dart";

int fromSnafu(String number) {
  int total = 0;
  final split = number.split("").reversed.toList();
  for (int index in range(split.length)) {
    int digit = pow(5, index).toInt();
    final maybeNumber = int.tryParse(split[index]);
    if (maybeNumber != null) {
      total += maybeNumber * digit;
    } else {
      if (split[index] == "=") {
        total -= (2 * digit);
      } else if (split[index] == "-") {
        total -= digit;
      } else {
        throw Error();
      }
    }
  }
  return total;
}

// i'm tired, recursion works
String toSnafu(int remaining) {
  if (remaining == 0) {
    return "";
  }
  final symbol = remaining % 5;
  if (symbol <= 2) {
    return "${toSnafu(remaining ~/ 5)}$symbol";
  } else if (symbol <= 4) {
    final suffix = symbol == 3 ? "=" : "-";
    // Add 1 since we are "subtracting" at the current remaining
    return "${toSnafu(1 + remaining ~/ 5)}$suffix";
  } else {
    // Should not happen
    throw Error();
  }
}

void main() async {
  final input = await parseInput("25/input");
  int total = 0;
  input.forEach((element) {
    total += fromSnafu(element);
  });
  print(toSnafu(total));
}
