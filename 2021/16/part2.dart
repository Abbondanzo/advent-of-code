import './part1.dart';

void main() async {
  final input = await parseInput('16/input');
  Stopwatch stopwatch = new Stopwatch()..start();
  final packets = processPacket(input);
  assert(packets.length == 1);
  print(packets[0].getValue());
  print('executed in ${stopwatch.elapsed.inMilliseconds}ms');
}
