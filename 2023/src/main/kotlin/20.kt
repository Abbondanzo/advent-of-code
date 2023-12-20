import Utils.readFileAsList
import java.util.*
import javax.sound.midi.Receiver

private object Day20 {

  enum class Pulse {
    LOW,
    HIGH,
  }

  sealed interface Module {

    val name: String

    val outputs: List<String>

    fun handlePulse(module: Module, pulse: Pulse)

    fun getNextPulse(): Pulse?

    data object Button : Module {
      override val name: String = "button"
      override val outputs: List<String> = listOf("broadcaster")

      override fun handlePulse(module: Module, pulse: Pulse) {
        // No-op
      }

      override fun getNextPulse(): Pulse {
        return Pulse.LOW
      }

    }

    data class Broadcaster(override val outputs: List<String>) : Module {
      override val name: String = "broadcaster"
      private lateinit var toSend: Pulse

      override fun handlePulse(module: Module, pulse: Pulse) {
        this.toSend = pulse
      }

      override fun getNextPulse(): Pulse {
        return this.toSend
      }
    }

    data class FlipFlop(override val name: String, override val outputs: List<String>) : Module {
      private var on: Boolean = false
      private lateinit var lastPulse: Pulse

      override fun handlePulse(module: Module, pulse: Pulse) {
        lastPulse = pulse
        if (pulse == Pulse.LOW) {
          this.on = !this.on
        }
      }

      override fun getNextPulse(): Pulse? {
        return if (lastPulse != Pulse.LOW) {
          null
        } else if (this.on) {
          Pulse.HIGH
        } else {
          Pulse.LOW
        }
      }
    }

    data class Conjunction(override val name: String, override val outputs: List<String>) : Module {
      private var receivedInputs = mutableMapOf<String, Pulse>()

      override fun handlePulse(module: Module, pulse: Pulse) {
        this.receivedInputs[module.name] = pulse
      }

      override fun getNextPulse(): Pulse {
        val allHighPulses = receivedInputs.all { it.value == Pulse.HIGH }
        receivedInputs = mutableMapOf()
        return if (allHighPulses) Pulse.LOW else Pulse.HIGH
      }
    }
  }

  fun toModules(input: List<String>): Map<String, Module> {
    val mutable = mutableMapOf<String, Module>()
    for (line in input) {
      val delimiter = " -> "
      val rawName = line.substringBefore(delimiter)
      val afters = line.substringAfter(delimiter).split(",").map(String::trim)
      val module =
          when (true) {
            (rawName == "broadcaster") -> Module.Broadcaster(afters)
            rawName.startsWith("%") -> Module.FlipFlop(rawName.substring(1), afters)
            rawName.startsWith("&") -> Module.Conjunction(rawName.substring(1), afters)
            else -> error("Unrecognized name $rawName")
          }
      mutable[module.name] = module
    }
    return mutable
  }

  data class Event(val sender: Module, val receiver: Module, val pulse: Pulse) {
    override fun toString(): String {
      return "${sender.name} -${pulse.name.lowercase(Locale.getDefault())}-> ${receiver.name}"
    }
  }

  private fun runCycle(input: Map<String, Module>): Pair<Long, Long> {
    val queue = mutableListOf(Event(Module.Button, input["broadcaster"]!!, Module.Button.getNextPulse()))
    var lowCount = 0L
    var highCount = 0L
    while (queue.isNotEmpty()) {
      val event = queue.removeAt(0)
      when (event.pulse) {
        Pulse.LOW -> lowCount++
        Pulse.HIGH -> highCount++
      }
      event.receiver.handlePulse(event.sender, event.pulse)
      val nextPulse = event.receiver.getNextPulse() ?: continue
      for (nextModuleName in event.receiver.outputs) {
        val nextModule = input[nextModuleName] ?: continue
        val nextEvent = Event(event.receiver, nextModule, nextPulse)
        queue.add(nextEvent)
      }
    }
    return Pair(lowCount, highCount)
  }

  fun partOne(input: Map<String, Module>): Long {
    var lowCount = 0L
    var highCount = 0L
    for (i in 1..1000) {
      println(i)
      val result = runCycle(input)
      lowCount += result.first
      highCount += result.second
    }
    return lowCount * highCount
  }

  fun partTwo(input: List<String>) {
    //    TODO("Not yet implemented")
  }
}

fun main() {
  val input = readFileAsList("20/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day20.partOne(Day20.toModules(input))}")
  println("Part 2: ${Day20.partTwo(input)}")
}
