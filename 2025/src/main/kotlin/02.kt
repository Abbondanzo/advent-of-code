import Utils.readFileAsList
import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.sign


private object Day02 {

    private fun parseInput(line: String): List<LongRange> {
        return line.split(',').map { range ->
            val r = range.split('-')
            r.first().toLong()..r.last().toLong()
        }
    }

    private fun Int.ceilDiv(other: Int): Int {
        return this.floorDiv(other) + this.rem(other).sign.absoluteValue
    }

    private fun partOne(ranges: List<LongRange>): Long {
        var output = 0L
        for (range in ranges) {
            val minSize = max(range.first.toString().length / 2, 1)
            val maxSize = max(range.last.toString().length.ceilDiv(2), 1)
            if (minSize != maxSize && minSize + 1 != maxSize) {
                error("invalid range $range")
            }
            var starter = if (minSize == maxSize || range.first.toString().length % 2 == 0) {
                range.first.toString().take(minSize).toInt()
            } else {
                ("1${"0".repeat(maxSize - 1)}").toInt()
            }
            val finisher = if (minSize == maxSize || range.last.toString().length % 2 == 0) {
                range.last.toString().take(maxSize).toInt()
            } else {
                ("1${"0".repeat(maxSize - 1)}").toInt()
            }
            if (starter > finisher) {
                error("Invalid finisher $starter $finisher $range ${"0".repeat(maxSize)}")
            }
            while (starter <= finisher) {
                val numberToCheck = starter.toString().repeat(2).toLong()
                if (numberToCheck in range) {
                    output += numberToCheck
                }
                starter++
            }
        }
        return output
    }

    private fun partTwo(ranges: List<LongRange>): Long {
        // Brute force
        var output = 0L
        for (range in ranges) {
            val repeaters = mutableSetOf<Long>()
            fun recursiveLongChecker(prefix: String) {
                val repeatsFirst = range.first.toString().length / prefix.length
                if (repeatsFirst >= 2) {
                    val repeatedFirst = prefix.repeat(repeatsFirst).toLong()
                    if (repeatedFirst in range) {
                        repeaters.add(repeatedFirst)
                    }
                }
                val repeatsLast = range.last.toString().length / prefix.length
                if (repeatsLast >= 2) {
                    val repeatedLast = prefix.repeat(repeatsLast).toLong()
                    if (repeatedLast in range) {
                        repeaters.add(repeatedLast)
                    }
                }
                if (repeatsFirst < 2 && repeatsLast < 2) {
                    return
                }
                for (i in 0..9) {
                    recursiveLongChecker(prefix + i)
                }
            }
            for (i in 1..9) {
                recursiveLongChecker("$i")
            }
            repeaters.forEach { output += it }
        }
        return output
    }

    fun main() {
        val input = readFileAsList("02/input").filter { it.isNotEmpty() }
        val ranges = parseInput(input[0])
        println("Part 1: ${partOne(ranges)}")
        println("Part 2: ${partTwo(ranges)}")
    }
}

fun main() {
    Day02.main()
}
