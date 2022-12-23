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

List<Coordinate> getRegions(Input input, int size) {
  List<Coordinate> regions = [];
  for (int y = 0; y < 4; y++) {
    final yCoord = y * size;
    if (yCoord >= input.tiles.length) {
      break;
    }
    final row = input.tiles[yCoord];
    for (int x = 0; x < 4; x++) {
      final xCoord = x * size;
      if (xCoord >= row.length) {
        break;
      }
      final spot = row[xCoord];
      if (spot != " ") {
        regions.add(Coordinate(xCoord, yCoord));
      }
    }
  }
  assert(regions.length == 6);
  return regions;
}

// List<Map<String, int>> getRegionMap(
//     Input input, int size, List<Coordinate> region) {
//   final outcomes = List.generate(6, (_) => Map());
// }

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

// class Transformer {
//   final int regionFrom;
//   final int regionTo;
//   final Coordinate offset;
//   final Coordinate Function(Coordinate pos) transformPos;
//   final int Function(int direction) transformDirection;

//   Transformer(this.regionFrom, this.regionTo, this.offset, this.transformPos,
//       this.transformDirection);
// }

// final SIZE = 50;

// final TRANSFORMERS = [
//   Transformer(2, 3, Coordinate(-SIZE, SIZE), (pos) {
//     return Coordinate(SIZE - 1, pos.y);
//   }, (direction) {
//     return rotateStep(direction, "R");
//   }),
//   Transformer(3, 2, Coordinate(SIZE, -SIZE), (pos) {
//     return Coordinate(pos.y, SIZE - 1);
//   }, (direction) {
//     return rotateStep(direction, "L");
//   }),
//   Transformer(2, 5, Coordinate(-SIZE, SIZE * 2), (pos) {
//     return Coordinate(SIZE - 1, SIZE - 1 - pos.y);
//   }, (direction) {
//     return rotateStep(rotateStep(direction, "L"), "L");
//   }),
//   Transformer(5, 2, Coordinate(SIZE, -SIZE * 2), (pos) {
//     return Coordinate(SIZE - 1, SIZE - 1 - pos.y);
//   }, (direction) {
//     return rotateStep(rotateStep(direction, "L"), "L");
//   }),
//   Transformer(2, 6, Coordinate(-SIZE * 2, SIZE * 3), (pos) {
//     return Coordinate(SIZE - 1 - pos.x, SIZE - 1);
//   }, (direction) {
//     return rotateStep(rotateStep(direction, "L"), "L");
//   }),
//   Transformer(6, 2, Coordinate(SIZE * 2, -SIZE * 3), (pos) {
//     return Coordinate(SIZE - 1 - pos.x, 0);
//   }, (direction) {
//     return rotateStep(rotateStep(direction, "L"), "L");
//   }),
//   Transformer(5, 6, Coordinate(-SIZE, SIZE), (pos) {
//     return Coordinate(SIZE - 1, pos.x);
//   }, (direction) {
//     return rotateStep(direction, "R");
//   }),
//   Transformer(6, 5, Coordinate(SIZE, -SIZE), (pos) {
//     return Coordinate(pos.y, SIZE - 1);
//   }, (direction) {
//     return rotateStep(direction, "L");
//   }),
//   Transformer(4, 1, Coordinate(SIZE, -SIZE * 2), (pos) {
//     return Coordinate(0, SIZE - 1 - pos.y);
//   }, (direction) {
//     return rotateStep(rotateStep(direction, "L"), "L");
//   }),
//   Transformer(1, 4, Coordinate(-SIZE, SIZE * 2), (pos) {
//     return Coordinate(0, SIZE - 1 - pos.y);
//   }, (direction) {
//     return rotateStep(rotateStep(direction, "L"), "L");
//   }),
//   Transformer(4, 3, Coordinate(SIZE, -SIZE), (pos) {
//     return Coordinate(0, pos.x);
//   }, (direction) {
//     return rotateStep(direction, "R");
//   }),
//   Transformer(3, 4, Coordinate(-SIZE, SIZE), (pos) {
//     return Coordinate(pos.y, 0);
//   }, (direction) {
//     return rotateStep(direction, "L");
//   }),
//   Transformer(1, 6, Coordinate(-SIZE, SIZE * 3), (pos) {
//     return Coordinate(SIZE - 1, pos.x);
//   }, (direction) {
//     return rotateStep(direction, "R");
//   }),
//   Transformer(6, 1, Coordinate(SIZE, -SIZE * 3), (pos) {
//     return Coordinate(pos.y, 0);
//   }, (direction) {
//     return rotateStep(direction, "L");
//   }),
// ];

class Transformer2 {
  final Coordinate Function(Coordinate pos) transformPos;
  final int Function(int direction) transformDir;

  Transformer2(this.transformPos, this.transformDir);
}

Map<String, Transformer2> getTransformerMap(int size) {
  final basicTransformer = Transformer2(
      (pos) => Coordinate(pos.x % size, pos.y % size),
      (direction) => direction);
  return {
    ">>": Transformer2((pos) {
      return Coordinate(size - 1, size - 1 - (pos.y % size));
    }, (direction) {
      return rotateStep(rotateStep(direction, "L"), "L");
    }),
    ">^": Transformer2((pos) {
      return Coordinate(size - 1 - (pos.y % size), 0);
    }, (direction) {
      return rotateStep(direction, "R");
    }),
    ">v": Transformer2((pos) {
      return Coordinate(pos.y % size, size - 1);
    }, (direction) {
      return rotateStep(direction, "L");
    }),
    "><": basicTransformer,
    "^^": Transformer2((pos) {
      return Coordinate(size - 1 - (pos.x % size), 0);
    }, (direction) {
      return rotateStep(rotateStep(direction, "L"), "L");
    }),
    "^>": Transformer2((pos) {
      return Coordinate(size - 1, size - 1 - (pos.x % size));
    }, (direction) {
      return rotateStep(direction, "L");
    }),
    "^<": Transformer2((pos) {
      return Coordinate(0, pos.x % size);
    }, (direction) {
      return rotateStep(direction, "R");
    }),
    "^v": basicTransformer,
    "<<": Transformer2((pos) {
      return Coordinate(0, size - 1 - (pos.y % size));
    }, (direction) {
      return rotateStep(rotateStep(direction, "R"), "R");
    }),
    "<^": Transformer2((pos) {
      return Coordinate(pos.y % size, 0);
    }, (direction) {
      return rotateStep(direction, "L");
    }),
    "<v": Transformer2((pos) {
      return Coordinate(size - 1 - (pos.y % size), size - 1);
    }, (direction) {
      return rotateStep(direction, "R");
    }),
    "<>": basicTransformer,
    "vv": Transformer2((pos) {
      return Coordinate(size - 1 - (pos.x % size), size - 1);
    }, (direction) {
      return rotateStep(rotateStep(direction, "R"), "R");
    }),
    "v>": Transformer2((pos) {
      return Coordinate(size - 1, pos.x % size);
    }, (direction) {
      return rotateStep(direction, "R");
    }),
    "v<": Transformer2((pos) {
      return Coordinate(0, size - 1 - (pos.x % size));
    }, (direction) {
      return rotateStep(direction, "L");
    }),
    "v^": basicTransformer,
  };
}

typedef RegionMap = Map<int, Map<String, int>>;

/**
 *  12
 *  3
 * 45
 * 6
 */
final RegionMap INPUT_REGION_MAP = {
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

/**
 *   1
 * 234
 *   56
 */
final RegionMap DEMO_REGION_MAP = {
  1: {"<": 3, "^": 2, ">": 6},
  2: {"^": 1, "<": 6, "v": 5},
  3: {"^": 1, "v": 5},
  4: {">": 6},
  5: {"<": 3, "v": 2},
  6: {"^": 4, ">": 1, "v": 2}
};

int getRegion(Coordinate spot, int size, List<Coordinate> regions) {
  final index = regions.indexWhere((region) {
    return region.x <= spot.x &&
        region.y <= spot.y &&
        region.x + size > spot.x &&
        region.y + size > spot.y;
  });
  assert(index >= 0);
  return index + 1;
}

void main() async {
  final useDemo = false;

  Input input;
  int size;
  RegionMap regionMap;

  if (useDemo) {
    input = await parseInput("22/demo");
    size = 4;
    regionMap = DEMO_REGION_MAP;
  } else {
    input = await parseInput("22/input");
    size = 50;
    regionMap = INPUT_REGION_MAP;
  }

  final start = startingPosition(input);
  final regions = getRegions(input, size);
  final transformers = getTransformerMap(size);
  final Set<String> seenTransformers = {};
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
        } else if (nextSpot == " ") {
          throw RangeError("No spot");
        } else {
          throw ErrorMessage("Not supposed to happen");
        }
      } catch (e) {
        if (!(e is RangeError)) {
          throw e;
        }

        // We are out of bounds. Compute this region and find its transformer
        final currentRegion = getRegion(Coordinate(curX, curY), size, regions);
        final directionStr = DIRECTIONS[direction];

        final destinationRegion = regionMap[currentRegion]![directionStr]!;
        final otherDirectionEntries = regionMap[destinationRegion]!.entries;
        final otherDirectionStr = otherDirectionEntries
            .firstWhere((e) => e.value == currentRegion)
            .key;

        final transformerKey = "$directionStr$otherDirectionStr";
        seenTransformers.add(transformerKey);
        final transformer = transformers[transformerKey]!;

        final transformedPos = transformer.transformPos(Coordinate(curX, curY));
        final offset = regions[destinationRegion - 1];
        final nextPosition = Coordinate(
            transformedPos.x + offset.x, transformedPos.y + offset.y);
        final spot = input.tiles[nextPosition.y][nextPosition.x];
        if (spot == ".") {
          curX = nextPosition.x;
          curY = nextPosition.y;
          direction = transformer.transformDir(direction);
          stepper = directionToStepper(direction);
        } else if (spot == "#") {
          break;
        } else {
          throw ErrorMessage("Not supposed to happen");
        }
      }
    }

    direction = rotateStep(direction, instruction.second);
  }

  final row = curY + 1;
  final col = curX + 1;

  // <138191, >24253
  print(toString(pathMap));
  print(seenTransformers);
  print((1000 * row) + (4 * col) + direction);
}
