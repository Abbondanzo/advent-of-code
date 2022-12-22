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

void main() async {
  final input = await parseInput("22/input");
  final start = startingPosition(input);
  final pathMap = input.tiles.map((row) => row.toList()).toList();

  int direction = 0;
  int curX = start.x;
  int curY = start.y;

  for (final instruction in input.instructions) {
    final stepper = directionToStepper(direction);

    for (int _ in range(instruction.first)) {
      pathMap[curY][curX] = DIRECTIONS[direction];

      final nextX = curX + stepper.x;
      final nextY = curY + stepper.y;
      // Left/right move
      if (stepper.y == 0) {
        // Off the board left
        final offLeft =
            nextX < 0 || (direction == 2 && input.tiles[curY][nextX] == " ");
        if (offLeft) {
          final row = input.tiles[curY];
          final colIndex = row.lastIndexWhere((element) => element != " ");
          if (colIndex >= 0 && input.tiles[curY][colIndex] == ".") {
            curX = colIndex;
            continue;
          } else {
            break;
          }
        }
        // Off the board right
        final offRight = nextX >= input.tiles[curY].length ||
            (direction == 0 && input.tiles[curY][nextX] == " ");
        if (offRight) {
          final row = input.tiles[nextY];
          final colIndex = row.indexWhere((element) => element != " ");
          if (colIndex >= 0 && input.tiles[curY][colIndex] == ".") {
            curX = colIndex;
            continue;
          } else {
            break;
          }
        }
      }
      // Up/down move
      if (stepper.x == 0) {
        // Off the board top
        final offTop = nextY < 0 ||
            (direction == 3 &&
                (input.tiles[nextY].length <= curX ||
                    input.tiles[nextY][curX] == " "));
        if (offTop) {
          int rowIndex = input.tiles.lastIndexWhere((row) {
            return row.length > curX && row[curX] != " ";
          });
          if (rowIndex >= 0 && input.tiles[rowIndex][curX] == ".") {
            curY = rowIndex;
            continue;
          } else {
            break;
          }
        }
        // Off the board bottom
        final offBottom = nextY >= input.tiles.length ||
            (direction == 1 &&
                (input.tiles[nextY].length <= curX ||
                    input.tiles[nextY][curX] == " "));
        if (offBottom) {
          int rowIndex = input.tiles.indexWhere((row) {
            return row.length > curX && row[curX] != " ";
          });
          if (rowIndex >= 0 && input.tiles[rowIndex][curX] == ".") {
            curY = rowIndex;
            continue;
          } else {
            break;
          }
        }
      }

      // Normal move
      final nextSpot = input.tiles[nextY][nextX];
      if (nextSpot == "#") {
        break;
      } else if (nextSpot == ".") {
        curX = nextX;
        curY = nextY;
      } else {
        throw Error();
      }
    }

    direction = rotateStep(direction, instruction.second);
  }

  final row = curY + 1;
  final col = curX + 1;

  // >89204
  print((1000 * row) + (4 * col) + direction);
}
