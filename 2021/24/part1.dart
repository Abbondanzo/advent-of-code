import '../utils.dart';

class Register {
  int value = 0;
}

abstract class Op {
  void run(int input);
}

class Input extends Op {
  final Register reg;

  Input(this.reg);

  @override
  void run(int input) {
    reg.value = input;
  }
}

class Add extends Op {
  final Register reg;

  Add(this.reg);

  @override
  void run(int input) {
    reg.value += input;
  }
}

class Multiply extends Op {
  final Register reg;

  Multiply(this.reg);

  @override
  void run(int input) {
    reg.value *= input;
  }
}

class Divide extends Op {
  final Register reg;

  Divide(this.reg);

  @override
  void run(int input) {
    reg.value = reg.value ~/ input;
  }
}

class Modulo extends Op {
  final Register reg;

  Modulo(this.reg);

  @override
  void run(int input) {
    reg.value = reg.value % input;
  }
}

class Equals extends Op {
  final Register reg;

  Equals(this.reg);

  @override
  void run(int input) {
    reg.value = reg.value == input ? 1 : 0;
  }
}

class ALU {
  final Register w = Register();
  final Register x = Register();
  final Register y = Register();
  final Register z = Register();

  late final void Function(int input) parser;
}

void main() async {
  final fileDescriptor = readFile('24/input');
  final lines = await fileDescriptor.toList();
  final tempALU = ALU();
  Register getRegister(String regName) {
    switch (regName) {
      case 'w':
        return tempALU.w;
      case 'x':
        return tempALU.x;
      case 'y':
        return tempALU.y;
      case 'z':
        return tempALU.z;
      default:
        throw Error();
    }
  }

  int getValueFromStr(String value) {
    if (['w', 'x', 'y', 'z'].contains(value)) {
      return getRegister(value).value;
    } else {
      return int.parse(value);
    }
  }

  lines.forEach((line) {
    final functors = line.split(' ');
    final opName = functors[0];
    final firstRegister = 
    switch (opName) {
      case 'inp':
        return Input(getRegister(functors[1]));
      default:
        throw Error();
    }
  });

  void parser(int input) {}
}
