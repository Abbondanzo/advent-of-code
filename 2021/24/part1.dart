import 'dart:collection';

import '../utils.dart';

class Register {
  int value = 0;
}

abstract class Instruction {
  void run(Queue<int> input);
}

class Input extends Instruction {
  final Register reg;

  Input(this.reg);

  @override
  void run(Queue<int> input) {
    reg.value = input.removeFirst();
  }
}

class Add extends Instruction {
  final Register reg;
  final int Function() value;

  Add(this.reg, this.value);

  @override
  void run(_) {
    reg.value += value();
  }
}

class Multiply extends Instruction {
  final Register reg;
  final int Function() value;

  Multiply(this.reg, this.value);

  @override
  void run(_) {
    reg.value *= value();
  }
}

class Divide extends Instruction {
  final Register reg;
  final int Function() value;

  Divide(this.reg, this.value);

  @override
  void run(_) {
    reg.value ~/= value();
  }
}

class Modulo extends Instruction {
  final Register reg;
  final int Function() value;

  Modulo(this.reg, this.value);

  @override
  void run(_) {
    reg.value %= value();
  }
}

class Equals extends Instruction {
  final Register reg;
  final int Function() value;

  Equals(this.reg, this.value);

  @override
  void run(_) {
    reg.value = reg.value == value() ? 1 : 0;
  }
}

class ALU {
  final Register w = Register();
  final Register x = Register();
  final Register y = Register();
  final Register z = Register();

  late final void Function(Queue<int> input) parser;

  @override
  String toString() {
    return 'ALU(w: ${w.value}, x: ${x.value}, y: ${y.value}, z: ${z.value})';
  }
}

ALU createALUFromInstructions(List<String> instructions) {
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

  /// Instructions:
  /// inp a - Read an input value and write it to variable a.
  /// add a b - Add the value of a to the value of b, then store the result in variable a.
  /// mul a b - Multiply the value of a by the value of b, then store the result in variable a.
  /// div a b - Divide the value of a by the value of b, truncate the result to an integer, then store the result in variable a. (Here, "truncate" means to round the value toward zero.)
  /// mod a b - Divide the value of a by the value of b, then store the remainder in variable a. (This is also called the modulo operation.)
  /// eql a b - If the value of a and b are equal, then store the value 1 in variable a. Otherwise, store the value 0 in variable a.
  final instructionRunners = instructions.map((line) {
    final functors = line.split(' ');
    final opName = functors[0];
    final register = getRegister(functors[1]);
    switch (opName) {
      case 'inp':
        return Input(register);
      case 'add':
        return Add(register, () => getValueFromStr(functors[2]));
      case 'mul':
        return Multiply(register, () => getValueFromStr(functors[2]));
      case 'div':
        return Divide(register, () => getValueFromStr(functors[2]));
      case 'mod':
        return Modulo(register, () => getValueFromStr(functors[2]));
      case 'eql':
        return Equals(register, () => getValueFromStr(functors[2]));
      default:
        throw Error();
    }
  });

  void parser(Queue<int> input) {
    instructionRunners.forEach((instr) {
      instr.run(input);
    });
  }

  tempALU.parser = parser;

  return tempALU;
}

void main() async {
  final fileDescriptor = readFile('24/demo');
  final lines = await fileDescriptor.toList();
  final alu = createALUFromInstructions(lines);
  final input = Queue<int>.from('15'.split('').map((e) => int.parse(e)));
  alu.parser(input);
  print(alu);
}
