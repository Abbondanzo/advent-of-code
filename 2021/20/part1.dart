import '../utils.dart';
import './parse.dart';

class Image {
  List<List<String>> _data;

  Image(this._data);

  List<List<String>> _copyData() {
    return List<List<String>>.from(_data.map((row) => List<String>.from(row)));
  }

  void pad(String defaultLight) {
    final List<List<String>> nextData = [];
    nextData.add(List.filled(_data[0].length + 4, defaultLight));
    nextData.add(List.filled(_data[0].length + 4, defaultLight));
    nextData.addAll(_data.map((row) =>
        [defaultLight, defaultLight, ...row, defaultLight, defaultLight]));
    nextData.add(List.filled(_data[0].length + 4, defaultLight));
    nextData.add(List.filled(_data[0].length + 4, defaultLight));
    this._data = nextData;
  }

  String _readCharAsBit(int row, int col, String defaultLight) {
    if (row < 0 || col < 0 || row >= _data.length || col >= _data[0].length) {
      return defaultLight == '#' ? '1' : '0';
    }
    return _data[row][col] == '#' ? '1' : '0';
  }

  int _readNine(int row, int col, String defaultLight) {
    List<String> outBin = [];
    for (int r in range(row - 1, row + 2)) {
      for (int c in range(col - 1, col + 2)) {
        outBin.add(_readCharAsBit(r, c, defaultLight));
      }
    }
    return int.parse(outBin.join(''), radix: 2);
  }

  void enhance(Input input, String defaultLight) {
    pad(defaultLight);
    final mutableData = _copyData();
    for (int row in range(_data.length)) {
      for (int col in range(_data[0].length)) {
        final shouldLight =
            input.isLight(_readNine(row - 1, col - 1, defaultLight));
        mutableData[row][col] = shouldLight ? '#' : '.';
      }
    }
    _data = mutableData;
  }

  void printImage() {
    _data.forEach((line) {
      print(line.join(''));
    });
    print('');
  }

  int countLit() {
    int lit = 0;
    _data.forEach((line) {
      line.forEach((element) {
        if (element == '#') {
          lit++;
        }
      });
    });
    return lit;
  }
}

Image runTimes(Input input, int iterations) {
  final image = Image(input.startInput);

  for (int run in range(iterations)) {
    final String defaultLight = input.isLight(0) && run % 2 == 1 ? '#' : '.';
    image.enhance(input, defaultLight);
  }

  return image;
}

void main() async {
  final input = await parseInput('20/input');
  final image = runTimes(input, 2);
  print(image.countLit());
}
