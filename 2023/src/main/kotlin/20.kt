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

    data class Empty(override val name: String) : Module {
      override val outputs: List<String> = listOf()

      override fun handlePulse(module: Module, pulse: Pulse) {
        // No-op
      }

      override fun getNextPulse(): Pulse? {
        return null
      }
    }

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
      var onPulse: (Module, Pulse) -> Unit = { _, _ -> }

      override fun handlePulse(module: Module, pulse: Pulse) {
        onPulse(module, pulse)
        this.receivedInputs[module.name] = pulse
      }

      override fun getNextPulse(): Pulse {
        val allHighPulses = receivedInputs.all { it.value == Pulse.HIGH }
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
    // Initialize all conjunction modules
    for (entry in mutable) {
      entry.value.outputs.forEach { moduleName ->
        val nextModule = mutable[moduleName] ?: return@forEach
        if (nextModule is Module.Conjunction) {
          nextModule.handlePulse(entry.value, Pulse.LOW)
        }
      }
    }
    return mutable
  }

  data class Event(val sender: Module, val receiver: Module, val pulse: Pulse) {
    override fun toString(): String {
      return "${sender.name} -${pulse.name.lowercase(Locale.getDefault())}-> ${receiver.name}"
    }

    fun process(): Pulse? {
      receiver.handlePulse(sender, pulse)
      return receiver.getNextPulse()
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
      val nextPulse = event.process() ?: continue
      for (nextModuleName in event.receiver.outputs) {
        val nextModule = input[nextModuleName] ?: Module.Empty(nextModuleName)
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
      val result = runCycle(input)
      lowCount += result.first
      highCount += result.second
    }
    return lowCount * highCount
  }

  private fun lcm(a: Long, b: Long): Long {
    val larger = if (a > b) a else b
    val max = a * b
    var lcm = larger
    while (lcm <= max) {
      if (lcm % a == 0L && lcm % b == 0L) {
        return lcm
      }
      lcm += larger
    }
    return max
  }

  fun partTwo(input: Map<String, Module>): Long {
    val predecessor = input.values.find { it.outputs.contains("rx") && it.outputs.size == 1 } ?: error("No way to rx")
    val requiredFromModuleCount = input.values.count { it.outputs.contains(predecessor.name) && it.outputs.size == 1 }
    val trackedCycles = mutableMapOf<String, Long>()
    var presses = 0L
    (predecessor as Module.Conjunction).onPulse = { from, pulse ->
      if (pulse == Pulse.HIGH) {
        trackedCycles[from.name] = presses
      }
    }
    while (trackedCycles.size < requiredFromModuleCount) {
      presses++
      runCycle(input)
    }
    return trackedCycles.values.reduce { acc, l -> lcm(acc, l) }
  }
}

fun main() {
  val input = readFileAsList("20/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day20.partOne(Day20.toModules(input))}")
  println("Part 2: ${Day20.partTwo(Day20.toModules(input))}")
}
