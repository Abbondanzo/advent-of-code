import './shared.dart';
import '../utils.dart';

void main() async {
  final input = await parseInput('13/input');
  int total = 0;
  for (int i in range(input.length)) {
    final pair = input[i];
    final result = compare(pair.first, pair.second);
    assert(result != null);
    if (result == true) {
      total += i + 1;
    }
  }
  // What is the sum of the indices of those pairs?
  print(total);
}
