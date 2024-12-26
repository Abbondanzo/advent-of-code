import Utils.readFileAsList
import kotlin.math.pow

private class ChronospatialComputer(
  private var regA: Long,
  private var regB: Long,
  private var regC: Long,
  private val debug: Boolean = false,
) {
  fun runProgram(instructions: List<Short>): List<Long> {
    var pointer = 0
    val output = mutableListOf<Long>()
    try {
      while (pointer < instructions.size) {
        val opcode = instructions[pointer]
        if (debug) {
          println("$regA $regB $regC $output")
          println("$pointer $opcode")
        }
        when (opcode.toInt()) {
          // adv
          0 -> {
            val operand = instructions[pointer + 1]
            val numerator = regA
            val denominator: Long = 2.toDouble().pow(comboOperand(operand).toDouble()).toLong()
            regA = numerator / denominator
            pointer += 2
          }
          // bxl
          1 -> {
            val operand = instructions[pointer + 1]
            regB = regB xor operand.toLong()
            pointer += 2
          }
          // bst
          2 -> {
            val operand = instructions[pointer + 1]
            regB = comboOperand(operand) % 8
            pointer += 2
          }
          // jnz
          3 -> {
            if (regA != 0L) {
              val operand = instructions[pointer + 1]
              pointer = operand.toInt()
            } else {
              pointer += 2
            }
          }
          // bxc
          4 -> {
            regB = regB xor regC
            pointer += 2
          }
          // out
          5 -> {
            val operand = instructions[pointer + 1]
            val result = comboOperand(operand) % 8
            output.add(result)
            pointer += 2
          }
          // bdv
          6 -> {
            val operand = instructions[pointer + 1]
            val numerator = regA
            val denominator: Long = 2.toDouble().pow(comboOperand(operand).toDouble()).toLong()
            regB = numerator / denominator
            pointer += 2
          }
          // cdv
          7 -> {
            val operand = instructions[pointer + 1]
            val numerator = regA
            val denominator: Long = 2.toDouble().pow(comboOperand(operand).toDouble()).toLong()
            regC = numerator / denominator
            pointer += 2
          }

          else -> error("Unrecognized opcode $opcode")
        }
      }
    } catch (ex: IndexOutOfBoundsException) {
      // Halt!
    }
    if (debug) {
      println("$regA $regB $regC $output")
    }
    return output
  }

  private fun comboOperand(operand: Short): Long {
    return when (operand.toInt()) {
      in 0..3 -> operand.toLong()
      4 -> regA
      5 -> regB
      6 -> regC
      else -> error("Unrecognized combo operand $operand")
    }
  }
}

private fun partOne(computer: ChronospatialComputer, program: List<Short>): String {
  val result = computer.runProgram(program)
  return result.joinToString(",")
}

private fun partTwo(program: List<Short>): Long {
  // The program can be rebuilt bit-by-bit, starting from the little end
  val potentials = program.reversed().fold(listOf(0L)) { temps, opcode ->
    temps.flatMap { startA ->
      val newTemps = mutableListOf<Long>()
      for (bits in 0..<8) {
        val maybeNewA = (startA shl 3) or bits.toLong()
        val matches = ChronospatialComputer(maybeNewA, 0, 0).runProgram(program).firstOrNull()?.toShort() == opcode
        if (matches) {
          newTemps.add(maybeNewA)
        }
      }
      newTemps
    }
  }
  return potentials.min()
}

fun main() {
  val input = readFileAsList("17/input").filter { it.isNotEmpty() }
  val regA = input[0].split(":")[1].trim().toLong()
  val regB = input[1].split(":")[1].trim().toLong()
  val regC = input[2].split(":")[1].trim().toLong()
  val program = input[3].split(":")[1].trim().split(",").map(String::toShort)

  println("Part 1: ${partOne(ChronospatialComputer(regA, regB, regC), program)}")
  println("Part 2: ${partTwo(program)}")
}
