import './part1.dart';

typedef Input = Map<String, List<String>>;
typedef Path = List<String>;

bool hasVisitedSmallCaveTwice(Path path) {
  List<String> smallCaves = [];
  bool hasVisitedSmallTwice = false;
  path.forEach((node) {
    if (isLowercase(node)) {
      if (smallCaves.contains(node)) {
        hasVisitedSmallTwice = true;
      }
      smallCaves.add(node);
    }
  });
  return hasVisitedSmallTwice;
}

Set<Path> runPath(Input input, Path path) {
  final curNode = path.last;
  if (curNode == 'end') return {path};
  final nextNodes = input[curNode]!.where((nextNode) {
    if (isLowercase(nextNode)) {
      if (nextNode == 'start' ||
          nextNode == 'end' ||
          hasVisitedSmallCaveTwice(path)) {
        return !path.contains(nextNode);
      }
    }
    return true;
  });
  Set<Path> paths = {};
  nextNodes.forEach((nextNode) {
    final nextPath = List<String>.from(path)..add(nextNode);
    paths.addAll(runPath(input, nextPath));
  });
  return paths;
}

void main() async {
  final paths = await parseInput();
  final runPaths = runPath(paths, ['start']);
  print(runPaths.length);
}
