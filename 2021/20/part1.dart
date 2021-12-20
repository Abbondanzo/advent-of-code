import '../utils.dart';
import './parse.dart';

final PADDING = 50;

Image padImage(Image image,
    {padTop: false, padBottom: false, padLeft: false, padRight: false}) {
  Image toReturn = [];
  if (padTop) {
    int finalRowLength = image[0].length;
    if (padLeft) {
      finalRowLength++;
    }
    if (padRight) {
      finalRowLength++;
    }
    toReturn.add(List.filled(finalRowLength, '.'));
  }

  List<String> rowTransform(List<String> row) {
    List<String> rowOut = [];
    if (padLeft) {
      rowOut.add('.');
    }
    rowOut.addAll(row);
    if (padRight) {
      rowOut.add('.');
    }
    return rowOut;
  }

  toReturn.addAll(image.map(rowTransform));

  if (padBottom) {
    toReturn.add(List.filled(toReturn[0].length, '.'));
  }

  return toReturn;
}

String readCharAsBit(Image image, int row, int col) {
  if (row < 0 || col < 0 || row >= image.length || col >= image[0].length) {
    return '0';
  }
  return image[row][col] == '#' ? '1' : '0';
}

int readNine(Image image, int row, int col) {
  List<String> outBin = [];
  for (int r in range(row - 1, row + 2)) {
    for (int c in range(col - 1, col + 2)) {
      outBin.add(readCharAsBit(image, r, c));
    }
  }
  return int.parse(outBin.join(''), radix: 2);
}

Image copyImage(Image image) {
  return List<List<String>>.from(
      image.map((row) => List<String>.from(row).toList())).toList();
}

Image enhanceImage(Input input, Image toEnhance) {
  final Image toReturn = copyImage(toEnhance);

  bool padLeft = false, padRight = false, padTop = false, padBottom = false;
  for (int row in range(toEnhance.length - 1)) {
    for (int col in range(toEnhance[0].length - 1)) {
      final shouldLight =
          input.isEnhancementLight(readNine(toEnhance, row, col));
      toReturn[row][col] = shouldLight ? '#' : '.';
      if (shouldLight) {
        padTop |= row < PADDING;
        padLeft |= col < PADDING;
        padRight |= col > toEnhance[0].length - PADDING;
        padBottom |= row > toEnhance.length - PADDING;
      }
    }
  }

  return shavePadding(padImage(toReturn,
      padLeft: padLeft,
      padRight: padRight,
      padBottom: padBottom,
      padTop: padTop));
}

Image shavePadding(Image image) {
  final halfPadding = (PADDING / 2).floor();
  print(halfPadding);
  Image shaved =
      image.sublist(halfPadding, image.length - halfPadding).map((row) {
    return row.sublist(halfPadding, row.length - halfPadding).toList();
  }).toList();
  for (int _ in range(halfPadding)) {
    shaved = padImage(shaved,
        padLeft: true, padRight: true, padBottom: true, padTop: true);
  }
  return shaved;
}

void printImage(Image image) {
  image.forEach((line) {
    print(line.join(''));
  });
  print('');
}

int countLit(Image image) {
  int lit = 0;
  final halfPadding = (PADDING / 2).floor();
  image.sublist(halfPadding, image.length - halfPadding).forEach((line) {
    line.sublist(halfPadding, line.length - halfPadding).forEach((element) {
      if (element == '#') {
        lit++;
      }
    });
  });
  return lit;
}

void main() async {
  final input = await parseInput('20/input');

  Image toEnhance = input.imageInput;

  for (int _ in range(PADDING)) {
    toEnhance = padImage(toEnhance,
        padLeft: true, padRight: true, padBottom: true, padTop: true);
  }

  // printImage(toEnhance);

  for (int _ in range(50)) {
    toEnhance = enhanceImage(input, toEnhance);
  }

  // printImage(toEnhance);

  printImage(toEnhance);
  print(countLit(toEnhance));
}
