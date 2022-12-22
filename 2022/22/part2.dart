import 'dart:ffi';

import "./shared.dart";
import "../utils.dart";

Coordinate startingPosition(Input input) {
  int rowIndex = 0;
  while (rowIndex < input.tiles.length) {
    final row = input.tiles[rowIndex];
    final colIndex = row.indexOf(".");
    if (colIndex >= 0) {
      return Coordinate(colIndex, rowIndex);
    }
    rowIndex++;
  }
  throw Error();
}

final DIRECTIONS = [">", "v", "<", "^"];

int rotateStep(int direction, String rotation) {
  if (rotation == "L") {
    return (direction - 1) % DIRECTIONS.length;
  } else if (rotation == "R") {
    return (direction + 1) % DIRECTIONS.length;
  } else {
    return direction;
  }
}

Coordinate directionToStepper(int direction) {
  switch (direction) {
    case 0:
      return Coordinate(1, 0);
    case 1:
      return Coordinate(0, 1);
    case 2:
      return Coordinate(-1, 0);
    case 3:
      return Coordinate(0, -1);
    default:
      throw Error();
  }
}

String toString(List<List<String>> map) {
  return map.map((e) => e.join("")).join("\n");
}

/**
 * 
 * Demo: 
 * 
 *   1
 * 234
 *   56
 * 
 * 4->6: y = size - x, x = 0, rotate R
 * 6->4: x = size, y = size - x, rotate L
 * 
 * 2->6: 
 * 6->2:
 * 
 * 5->2:
 * 2->5:
 * 
 * 5->3:
 * 3->5:
 * 
 * 1->2:
 * 2->1:
 * 
 * 1->3:
 * 3->1:
 * 
 * 1->6:
 * 6->1: 
 * 
 * My input:
 *  12
 *  3
 * 45
 * 6
 *
 * 
 * 2 bottom -> 3: y=x, x=size, R
 * 3 right -> 2: x=y, y=size, L
 * 
 * 2 right -> 5: x=size, y=size-y, RR
 * 5 right -> 2: x=size, y=size-y, RR
 * 
 * 2 top -> 6: x=size-x, y=size, RR
 * 6 bottom -> 2: x=size-x, y=0, RR
 * 
 * 5 bottom -> 6: x=size, y=x, R
 * 6 right -> 5: x=y, y=size, L
 * 
 * 4 left -> 1: x=0, y=size-y, RR
 * 1 left -> 4: x=0, y=size-y, RR
 * 
 * 4 top -> 3: x=0, y=x, R
 * 3 left -> 4: x=y, y=0, L
 * 
 * 1 top -> 6: x=size, y=x, R
 * 6 left -> 1: x=y, y=0, L
 */

class Transformer {
  final int regionFrom;
  final int regionTo;
  final Coordinate offset;
  final Coordinate Function(Coordinate pos) transformPos;
  final int Function(int direction) transformDirection;

  Transformer(this.regionFrom, this.regionTo, this.offset, this.transformPos,
      this.transformDirection);
}

final SIZE = 50;

final TRANSFORMERS = [
  Transformer(2, 3, Coordinate(-SIZE, SIZE), (pos) {
    return Coordinate(SIZE - 1, pos.y);
  }, (direction) {
    return rotateStep(direction, "R");
  }),
  Transformer(3, 2, Coordinate(SIZE, -SIZE), (pos) {
    return Coordinate(pos.y, SIZE - 1);
  }, (direction) {
    return rotateStep(direction, "L");
  }),
  Transformer(2, 5, Coordinate(-SIZE, SIZE * 2), (pos) {
    return Coordinate(SIZE - 1, SIZE - 1 - pos.y);
  }, (direction) {
    return rotateStep(rotateStep(direction, "L"), "L");
  }),
  Transformer(5, 2, Coordinate(SIZE, -SIZE * 2), (pos) {
    return Coordinate(SIZE - 1, SIZE - 1 - pos.y);
  }, (direction) {
    return rotateStep(rotateStep(direction, "L"), "L");
  }),
  Transformer(2, 6, Coordinate(-SIZE * 2, SIZE * 3), (pos) {
    return Coordinate(SIZE - 1 - pos.x, SIZE - 1);
  }, (direction) {
    return rotateStep(rotateStep(direction, "L"), "L");
  }),
  Transformer(6, 2, Coordinate(SIZE * 2, -SIZE * 3), (pos) {
    return Coordinate(SIZE - 1 - pos.x, 0);
  }, (direction) {
    return rotateStep(rotateStep(direction, "L"), "L");
  }),
  Transformer(5, 6, Coordinate(-SIZE, SIZE), (pos) {
    return Coordinate(SIZE - 1, pos.x);
  }, (direction) {
    return rotateStep(direction, "R");
  }),
  Transformer(6, 5, Coordinate(SIZE, -SIZE), (pos) {
    return Coordinate(pos.y, SIZE - 1);
  }, (direction) {
    return rotateStep(direction, "L");
  }),
  Transformer(4, 1, Coordinate(SIZE, -SIZE * 2), (pos) {
    return Coordinate(0, SIZE - 1 - pos.y);
  }, (direction) {
    return rotateStep(rotateStep(direction, "L"), "L");
  }),
  Transformer(1, 4, Coordinate(-SIZE, SIZE * 2), (pos) {
    return Coordinate(0, SIZE - 1 - pos.y);
  }, (direction) {
    return rotateStep(rotateStep(direction, "L"), "L");
  }),
  Transformer(4, 3, Coordinate(SIZE, -SIZE), (pos) {
    return Coordinate(0, pos.x);
  }, (direction) {
    return rotateStep(direction, "R");
  }),
  Transformer(3, 4, Coordinate(-SIZE, SIZE), (pos) {
    return Coordinate(pos.y, 0);
  }, (direction) {
    return rotateStep(direction, "L");
  }),
  Transformer(1, 6, Coordinate(-SIZE, SIZE * 3), (pos) {
    return Coordinate(SIZE - 1, pos.x);
  }, (direction) {
    return rotateStep(direction, "R");
  }),
  Transformer(6, 1, Coordinate(SIZE, -SIZE * 3), (pos) {
    return Coordinate(pos.y, 0);
  }, (direction) {
    return rotateStep(direction, "L");
  }),
];

final Map<int, Map<String, int>> REGION_MAP = {
  1: {"^": 6, "<": 4},
  2: {
    ">": 5,
    "^": 6,
    "v": 3,
  },
  3: {">": 2, "<": 4},
  4: {
    "<": 1,
    "^": 3,
  },
  5: {
    ">": 2,
    "v": 6,
  },
  6: {"v": 2, ">": 5, "<": 1},
};

final Map<int, Coordinate> REGION_OFFSETS = {
  1: Coordinate(SIZE, 0),
  2: Coordinate(SIZE * 2, 0),
  3: Coordinate(SIZE, SIZE),
  4: Coordinate(0, SIZE * 2),
  5: Coordinate(SIZE, SIZE * 2),
  6: Coordinate(0, SIZE * 3)
};

int getRegion(int curX, int curY) {
  if (curY < SIZE) {
    if (curX >= SIZE * 2) {
      return 2;
    } else {
      return 1;
    }
  }
  if (curY < SIZE * 2) {
    return 3;
  }
  if (curY < SIZE * 3) {
    if (curX >= SIZE) {
      return 5;
    } else {
      return 4;
    }
  }
  return 6;
}

void main() async {
  final input = await parseInput("22/input");
  final start = startingPosition(input);
  final pathMap = input.tiles.map((row) => row.toList()).toList();

  int direction = 0;
  int curX = start.x;
  int curY = start.y;

  for (final instruction in input.instructions) {
    Coordinate stepper = directionToStepper(direction);

    for (int _ in range(instruction.first)) {
      pathMap[curY][curX] = DIRECTIONS[direction];

      final nextX = curX + stepper.x;
      final nextY = curY + stepper.y;

      try {
        // Normal move
        final nextSpot = input.tiles[nextY][nextX];
        if (nextSpot == "#") {
          break;
        } else if (nextSpot == ".") {
          curX = nextX;
          curY = nextY;
        } else {
          throw ErrorMessage("Not supposed to happen");
        }
        direction = rotateStep(direction, instruction.second);
      } catch (e) {
        if (e is ErrorMessage) {
          throw e;
        }

        // We are out of bounds. Compute this region and find its transformer
        int currentRegion = getRegion(curX, curY);
        String directionStr = DIRECTIONS[direction];
        int destinationRegion = REGION_MAP[currentRegion]![directionStr]!;
        final transformer = TRANSFORMERS.firstWhere((element) =>
            element.regionFrom == currentRegion &&
            element.regionTo == destinationRegion);
        final transformedPos =
            transformer.transformPos(Coordinate(curX % SIZE, curY % SIZE));
        final offset = REGION_OFFSETS[destinationRegion]!;
        final nextPosition = Coordinate(
            transformedPos.x + offset.x, transformedPos.y + offset.y);
        final spot = input.tiles[nextPosition.y][nextPosition.x];
        if (spot == ".") {
          curX = nextPosition.x;
          curY = nextPosition.y;
          direction = transformer.transformDirection(direction);
        } else if (spot == "#") {
          break;
        } else {
          throw Error();
        }
      }
    }
  }

  final row = curY + 1;
  final col = curX + 1;

  // <138191
  print((1000 * row) + (4 * col) + direction);
}
