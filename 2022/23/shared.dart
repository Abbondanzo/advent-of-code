import "../utils.dart";

typedef Input = Set<Coordinate>;

Future<Input> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();

  Set<Coordinate> elves = {};
  for (int y in range(inputLineList.length)) {
    final row = inputLineList[y].split("");
    for (int x in range(row.length)) {
      final char = row[x];
      if (char == "#") {
        elves.add(Coordinate(x, y));
      }
    }
  }
  return elves;
}

Coordinate getMinimums(Input input) {
  assert(input.length > 0);
  int minX = input.first.x;
  int minY = input.first.y;
  for (final coord in input) {
    if (coord.x < minX) minX = coord.x;
    if (coord.y < minY) minY = coord.y;
  }
  return Coordinate(minX, minY);
}

Coordinate getMaximums(Input input) {
  assert(input.length > 0);
  int maxX = input.first.x;
  int maxY = input.first.y;
  for (final coord in input) {
    if (coord.x > maxX) maxX = coord.x;
    if (coord.y > maxY) maxY = coord.y;
  }
  return Coordinate(maxX, maxY);
}

String toString(Input input) {
  final min = getMinimums(input);
  final max = getMaximums(input);
  return range(min.y, max.y + 1).map((y) {
    return range(min.x, max.x + 1).map((x) {
      if (input.contains(Coordinate(x, y))) {
        return "#";
      } else {
        return ".";
      }
    }).join("");
  }).join("\n");
}

bool canMove(Set<Coordinate> coordinates, Coordinate elf) {
  for (int x in range(elf.x - 1, elf.x + 2)) {
    for (int y in range(elf.y - 1, elf.y + 2)) {
      if (x == elf.x && y == elf.y) continue;
      if (coordinates.contains(Coordinate(x, y))) {
        return true;
      }
    }
  }
  return false;
}

Map<Coordinate, Coordinate> generateProposals(
    Set<Coordinate> elves, int round) {
  // N = 0 -> -y
  // S = 1 -> +y
  // W = 2 -> -x
  // E = 3 -> +x
  final direction = round % 4;
  // key = cur, value = proposal
  final Map<Coordinate, Coordinate> proposals = {};
  final Set<Coordinate> toIgnore = {};
  for (final elf in elves) {
    if (!canMove(elves, elf)) continue;

    for (int addl in range(4)) {
      final consideredDirection = (direction + addl) % 4;
      bool isMoving = false;
      // North
      if (consideredDirection == 0) {
        bool canMove = true;
        for (int x in range(elf.x - 1, elf.x + 2)) {
          if (elves.contains(Coordinate(x, elf.y - 1))) {
            canMove = false;
            break;
          }
        }
        if (canMove) {
          isMoving = true;
          final proposal = Coordinate(elf.x, elf.y - 1);
          if (proposals.containsValue(proposal)) {
            toIgnore.add(proposal);
          } else {
            proposals[elf] = proposal;
          }
        }
      }
      // South
      else if (consideredDirection == 1) {
        bool canMove = true;
        for (int x in range(elf.x - 1, elf.x + 2)) {
          if (elves.contains(Coordinate(x, elf.y + 1))) {
            canMove = false;
            break;
          }
        }
        if (canMove) {
          isMoving = true;
          final proposal = Coordinate(elf.x, elf.y + 1);
          if (proposals.containsValue(proposal)) {
            toIgnore.add(proposal);
          } else {
            proposals[elf] = proposal;
          }
        }
      }
      // West
      else if (consideredDirection == 2) {
        bool canMove = true;
        for (int y in range(elf.y - 1, elf.y + 2)) {
          if (elves.contains(Coordinate(elf.x - 1, y))) {
            canMove = false;
            break;
          }
        }
        if (canMove) {
          isMoving = true;
          final proposal = Coordinate(elf.x - 1, elf.y);
          if (proposals.containsValue(proposal)) {
            toIgnore.add(proposal);
          } else {
            proposals[elf] = proposal;
          }
        }
      }
      // East
      else if (consideredDirection == 3) {
        bool canMove = true;
        for (int y in range(elf.y - 1, elf.y + 2)) {
          if (elves.contains(Coordinate(elf.x + 1, y))) {
            canMove = false;
            break;
          }
        }
        if (canMove) {
          isMoving = true;
          final proposal = Coordinate(elf.x + 1, elf.y);
          if (proposals.containsValue(proposal)) {
            toIgnore.add(proposal);
          } else {
            proposals[elf] = proposal;
          }
        }
      }

      if (isMoving) {
        break;
      }
    }
  }
  toIgnore.forEach((element) {
    proposals.removeWhere((key, value) => value == element);
  });
  return proposals;
}
