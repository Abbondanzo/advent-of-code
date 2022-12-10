class Instruction {}

class Noop extends Instruction {}

class AddX extends Instruction {
  int value;

  AddX(this.value);
}

class SignalProcessor {
  int cycle;
  int register;
  List<Instruction> instructions;
  AddX? inProgressInstruction;

  SignalProcessor()
      : cycle = 0,
        register = 1,
        instructions = [];

  void setInstructions(List<Instruction> instructions) {
    this.instructions = instructions;
  }

  int runToCycle(int cycle) {
    int duringCycle = this.register;
    while (this.cycle < cycle) {
      duringCycle = this.register;
      if (instructions.isEmpty) {
        this.cycle = cycle;
        break;
      }
      if (inProgressInstruction != null) {
        this.register += inProgressInstruction!.value;
        inProgressInstruction = null;
      } else {
        final instruction = instructions.removeAt(0);
        if (instruction is AddX) {
          inProgressInstruction = instruction;
        } else if (instruction is Noop) {
          // Noop
        }
      }
      this.cycle++;
    }
    return duringCycle;
  }
}
