import './shared.dart';

void main() async {
  final input = await parseInput('13/input');
  final List<Node> nodes = [];
  input.forEach((pair) {
    nodes.add(pair.first);
    nodes.add(pair.second);
  });

  final decoderA = ListNode([
    ListNode([ItemNode(2)])
  ]);
  final decoderB = ListNode([
    ListNode([ItemNode(6)])
  ]);

  nodes.insert((nodes.length / 2).floor(), decoderA);
  nodes.insert((nodes.length / 2).floor(), decoderB);

  nodes.sort((a, b) {
    final decision = compare(a, b);
    if (decision == true) {
      return -1;
    } else {
      return 1;
    }
  });

  final indexA = nodes.indexOf(decoderA);
  final indexB = nodes.indexOf(decoderB);

  // What is the decoder key for the distress signal?
  print((indexA + 1) * (indexB + 1));
}
