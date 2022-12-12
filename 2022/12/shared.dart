import '../utils.dart';

Future<List<List<String>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  return inputLineList.map((line) => line.split("")).toList();
}

bool canJump(Coordinate cur, Coordinate next, List<List<String>> input) {
  final strCur = input[cur.y][cur.x];
  final strNext = input[next.y][next.x];
  if (strCur == "S" && strNext == "a") {
    return true;
  }
  if (strNext == "S") {
    return false;
  }
  if (strNext == "E") {
    return strCur == "z";
  }
  return (strNext.codeUnitAt(0) - strCur.codeUnitAt(0)) <= 1;
}

List<Coordinate> edges(Coordinate pos, List<List<String>> input) {
  final List<Coordinate> edges = [];

  // Left
  if (pos.x > 0) {
    final left = Coordinate(pos.x - 1, pos.y);
    if (canJump(pos, left, input)) {
      edges.add(left);
    }
  }

  // Right
  if (pos.x < input[0].length - 1) {
    final right = Coordinate(pos.x + 1, pos.y);
    if (canJump(pos, right, input)) {
      edges.add(right);
    }
  }

  // Up
  if (pos.y > 0) {
    final up = Coordinate(pos.x, pos.y - 1);
    if (canJump(pos, up, input)) {
      edges.add(up);
    }
  }

  // Down
  if (pos.y < input.length - 1) {
    final down = Coordinate(pos.x, pos.y + 1);
    if (canJump(pos, down, input)) {
      edges.add(down);
    }
  }

  return edges;
}

Coordinate removeSmallest(List<Coordinate> queue, Map<Coordinate, int> dist) {
  queue.sort((a, b) {
    if (dist.containsKey(a) && !dist.containsKey(b)) {
      return -1;
    }
    if (dist.containsKey(b) && !dist.containsKey(a)) {
      return 1;
    }
    if (!dist.containsKey(a) && !dist.containsKey(b)) {
      return 0;
    }
    return dist[a]! > dist[b]! ? 1 : -1;
  });
  return queue.removeAt(0);
}

List<Coordinate> bfs(Coordinate start, List<List<String>> input) {
  List<Coordinate> queue = [];
  Set<Coordinate> explored = new Set();
  Map<Coordinate, Coordinate> parents = {};
  Map<Coordinate, int> dist = {};
  queue.add(start);
  explored.add(start);
  dist[start] = 0;
  while (queue.isNotEmpty) {
    final v = removeSmallest(queue, dist);
    final str = input[v.y][v.x];
    if (str == "E") {
      Coordinate? toExplore = v;
      List<Coordinate> path = [];
      while (toExplore != null) {
        path.add(toExplore);
        toExplore = parents[toExplore];
      }
      return path;
    }
    for (Coordinate coord in edges(v, input)) {
      if (!explored.contains(coord)) {
        explored.add(coord);
        parents[coord] = v;
        dist[coord] = dist[v]! + 1;
        queue.add(coord);
      }
    }
  }

  for (int y in range(input.length)) {
    for (int x in range(input[0].length)) {
      if (explored.contains(Coordinate(x, y))) {
        input[y][x] = ".";
      }
    }
  }

  print(input.map((line) => line.join("")).join("\n"));
  throw Error();
}
