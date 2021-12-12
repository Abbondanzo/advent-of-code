import '../utils.dart';

typedef Input = Map<String, List<String>>;
typedef Path = List<String>;

Future<Input> parseInput() async {
  final inputLines = readFile('12/input');
  final inputLineList = await inputLines.toList();
  final Input paths = Map();
  inputLineList.forEach((line) {
    final nodes = line.split('-');
    assert(nodes.length == 2);
    paths.update(
      nodes[0],
      (dests) {
        dests.add(nodes[1]);
        return dests;
      },
      ifAbsent: () => [nodes[1]],
    );
    paths.update(
      nodes[1],
      (dests) {
        dests.add(nodes[0]);
        return dests;
      },
      ifAbsent: () => [nodes[0]],
    );
  });
  return paths;
}

bool isLowercase(String nodeName) {
  return nodeName.toLowerCase() == nodeName;
}

Set<Path> runPath(Input input, Path path) {
  final curNode = path.last;
  if (curNode == 'end') return {path};
  final nextNodes = input[curNode]!.where((nextNode) {
    return isLowercase(nextNode) ? !path.contains(nextNode) : true;
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
