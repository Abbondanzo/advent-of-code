import '../utils.dart';
import './shared.dart';

Input shuffleInput(Input inputList) {
  final indexList = List.generate(inputList.length, (index) => index);

  for (int index in range(inputList.length)) {
    if (inputList[index] == 0) continue;
    final oldIndex = indexList.indexOf(index);
    final numberIndex = indexList.removeAt(oldIndex);
    final number = inputList[numberIndex];
    final newIndex = (oldIndex + number) % indexList.length;
    if (newIndex == 0 && number < 0) {
      indexList.add(index);
    } else {
      indexList.insert(newIndex, index);
    }
  }
  return indexList.map((e) => inputList[e]).toList();
}

void main() async {
  final inputList = await parseInput('20/input');
  final shuffledList = shuffleInput(inputList);

  final indexOfZero = shuffledList.indexOf(0);
  int total = 0;

  for (int i = 1000; i < 3001; i += 1000) {
    final index = (i + indexOfZero) % shuffledList.length;
    total += shuffledList[index];
  }

  print(total);
}
