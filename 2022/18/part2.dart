import './shared.dart';
import '../utils.dart';

Coordinate3D min(Input input) {
  assert(input.length > 0);
  int minX = input[0].x;
  int minY = input[0].y;
  int minZ = input[0].z;
  for (int i in range(1, input.length)) {
    final coord = input[i];
    if (coord.x < minX) minX = coord.x;
    if (coord.y < minY) minY = coord.y;
    if (coord.z < minZ) minZ = coord.z;
  }
  return Coordinate3D(minX, minY, minZ);
}

Coordinate3D max(Input input) {
  assert(input.length > 0);
  int maxX = input[0].x;
  int maxY = input[0].y;
  int maxZ = input[0].z;
  for (int i in range(1, input.length)) {
    final coord = input[i];
    if (coord.x > maxX) maxX = coord.x;
    if (coord.y > maxY) maxY = coord.y;
    if (coord.z > maxZ) maxZ = coord.z;
  }
  return Coordinate3D(maxX, maxY, maxZ);
}

void main() async {
  final input = await parseInput('18/input');
  final minInput = min(input);
  final maxInput = max(input);
  final Set<Coordinate3D> air = {};
  for (int x in range(minInput.x, maxInput.x + 1)) {
    for (int y in range(minInput.y, maxInput.y + 1)) {
      for (int z in range(minInput.z, maxInput.z + 1)) {
        final coord = Coordinate3D(x, y, z);
        if (!input.contains(coord)) {
          air.add(coord);
        }
      }
    }
  }
  List<List<Coordinate3D>> pockets = [];
  for (final coord in air) {
    List<Coordinate3D>? touchingPocket;
    for (final pocket in pockets) {
      if (pocket.any((element) => element.touching(coord))) {
        touchingPocket = pocket;
        break;
      }
    }
    if (touchingPocket != null) {
      touchingPocket.add(coord);
    } else {
      pockets.add([coord]);
    }
  }
  // eh I'm tired
  while (true) {
    final Map<int, int> toCombine = Map();
    for (int i in range(pockets.length)) {
      for (int j in range(i + 1, pockets.length)) {
        if (i == j) {
          continue;
        }
        final pocketA = pockets[i];
        final pocketB = pockets[j];
        final canTouch = pocketA.any((elementA) =>
            pocketB.any((elementB) => elementA.touching(elementB)));
        if (canTouch) {
          toCombine[j] = toCombine[i] ?? i;
        }
      }
    }
    if (toCombine.isEmpty) {
      break;
    }
    final List<List<Coordinate3D>> newPockets = [];
    toCombine.entries.forEach((element) {
      final finalPocket = pockets[element.value];
      finalPocket.addAll(pockets[element.key]);
    });
    for (int i in range(pockets.length)) {
      if (!toCombine.keys.contains(i)) {
        newPockets.add(pockets[i]);
      }
    }
    pockets = newPockets;
  }

  final internalPockets = pockets.where((pocket) {
    final nullLol = Coordinate3D(999, 999, 999);
    final Coordinate3D? hasOutside = pocket.firstWhere(
        (element) =>
            element.x == minInput.x ||
            element.x == maxInput.x ||
            element.y == minInput.y ||
            element.y == maxInput.y ||
            element.z == maxInput.z,
        orElse: () => nullLol);
    return hasOutside == nullLol;
  });
  final List<int> coalescedPockets = [];

  final naiveSides = exteriorSides(input);
  int toScrub = 0;
  for (final pocket in internalPockets) {
    // print(pocket);
    toScrub += exteriorSides(pocket);
  }

  print(naiveSides);
  print(toScrub);
  print(naiveSides - toScrub);
}
