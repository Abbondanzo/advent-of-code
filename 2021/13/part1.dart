import 'package:equatable/equatable.dart';

import '../utils.dart';

class Coord extends Equatable {
  final int x;
  final int y;

  Coord(this.x, this.y);

  @override
  List<Object?> get props => [x * 100000, y];

  @override
  String toString() {
    return 'Coord($x, $y)';
  }

  Coord fold(Fold fold) {
    if (fold.axis == 'x') {
      return _foldX(fold.value);
    } else if (fold.axis == 'y') {
      return _foldY(fold.value);
    } else {
      throw new ArgumentError('Fold must be of type "x" or "y"');
    }
  }

  Coord _foldX(int x) {
    assert(x != this.x);
    if (this.x < x) {
      return this;
    } else {
      final distanceToX = this.x - x;
      return Coord(x - distanceToX, this.y);
    }
  }

  Coord _foldY(int y) {
    assert(y != this.y);
    if (this.y < y) {
      return this;
    } else {
      final distanceToY = this.y - y;
      return Coord(this.x, y - distanceToY);
    }
  }
}

class Fold extends Equatable {
  final String axis;
  final int value;

  Fold(this.axis, this.value);

  @override
  List<Object?> get props => [axis, value];

  @override
  String toString() {
    return 'Fold($axis=$value)';
  }
}

class Input {
  final Set<Coord> coords;
  final Set<Fold> folds;

  Input(this.coords, this.folds);

  Set<Coord> runOneFold() {
    return this.coords.map((coord) => coord.fold(this.folds.first)).toSet();
  }

  Set<Coord> runFolds() {
    final coordsCopy = Set.of(this.coords);
    return this.folds.fold<Set<Coord>>(coordsCopy, (previousValue, fold) {
      return previousValue.map((coord) => coord.fold(fold)).toSet();
    });
  }

  int finalSize() {
    int? smallestX;
    int? smallestY;
    this.folds.forEach((fold) {
      if (fold.axis == 'x') {
        if (smallestX == null || fold.value < smallestX!) {
          smallestX = fold.value;
        }
      } else if (fold.axis == 'y') {
        if (smallestY == null || fold.value < smallestY!) {
          smallestY = fold.value;
        }
      }
    });
    print(smallestX);
    print(smallestY);
    return smallestX! * smallestY!;
  }
}

Future<Input> parseInput(String inputFile) async {
  final inputLines = readFile(inputFile);
  final inputLineList = await inputLines.toList();

  final Set<Coord> coords = Set();
  final Set<Fold> folds = Set();

  bool isFoldAlong = false;
  inputLineList.forEach((line) {
    if (!isFoldAlong) {
      if (line == '') {
        isFoldAlong = true;
      } else {
        final strCoords =
            line.split(',').map((number) => int.parse(number)).toList();
        assert(strCoords.length == 2);
        coords.add(Coord(strCoords[0], strCoords[1]));
      }
    } else {
      final foldValues = line.split('fold along ')[1].split('=');
      assert(foldValues.length == 2);
      folds.add(Fold(foldValues[0], int.parse(foldValues[1])));
    }
  });

  return Input(coords, folds);
}

void main() async {
  final input = await parseInput('13/input');

  /// How many dots are visible after completing just the first fold instruction on your transparent paper?
  print(input.runOneFold().length);
}
