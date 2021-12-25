import '../utils.dart';

class Input {
  final List<int> aList;
  final List<int> bList;
  final List<int> cList;

  Input(this.aList, this.bList, this.cList);
}

Future<Input> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();

  final List<int> aList = [];
  final List<int> bList = [];
  final List<int> cList = [];

  final aLineRegex = RegExp(r'div z (\d+)');
  final bLineRegex = RegExp(r'add x (-?\d+)');
  final cLineRegex = RegExp(r'add y (\d+)');

  /// Each ALU is 18 lines long, with 14 total instructions
  assert(lines.length == 18 * 14);
  for (int instr in range(14)) {
    final aLineIdx = (instr * 18) + 4;
    aList.add(int.parse(aLineRegex.firstMatch(lines[aLineIdx])!.group(1)!));
    final bLineIdx = (instr * 18) + 5;
    bList.add(int.parse(bLineRegex.firstMatch(lines[bLineIdx])!.group(1)!));
    final cLineIdx = (instr * 18) + 15;
    cList.add(int.parse(cLineRegex.firstMatch(lines[cLineIdx])!.group(1)!));
  }

  return Input(aList, bList, cList);
}
