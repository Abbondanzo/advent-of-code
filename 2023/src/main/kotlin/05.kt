import Utils.readFileAsList

data class Range(
    val sourceStart: Long,
    val destinationStart: Long,
    val gap: Long,
)

data class RangeMap(
    val ranges: List<Range>,
) {
    fun mapValue(input: Long): Long {
        for (range in ranges) {
            if (input in range.destinationStart..<(range.destinationStart + range.gap)) {
                val toAdd = range.sourceStart - range.destinationStart
                return input + toAdd
            }
        }
        return input
    }
}

private fun getSeeds(line: String): List<Long> {
    return line.split(":")[1].split(" ").map(String::trim).filter(String::isNotEmpty).map(String::toLong)
}

private fun getSeedRanges(line: String): List<LongRange> {
    val seeds = getSeeds(line)
    val ranges = mutableListOf<LongRange>()
    for (i in seeds.indices step 2) {
        val range = seeds[i]..<(seeds[i] + seeds[i + 1])
        ranges.add(range)
    }
    return ranges
}

private fun getRangeMaps(input: List<String>): List<RangeMap> {
    val maps = mutableListOf<RangeMap>()
    var ranges = mutableListOf<Range>()
    val digitRegex = Regex("\\d")
    for ((index, line) in input.withIndex()) {
        if (index == 0) {
            continue
        }
        if (!line.contains(digitRegex)) {
            if (ranges.isNotEmpty()) {
                maps.add(RangeMap(ranges))
                ranges = mutableListOf()
            }
        } else {
            val values = line.split(" ").map(String::trim).filter(String::isNotEmpty).map(String::toLong)
            assert(values.size == 3)
            ranges.add(Range(values[0], values[1], values[2]))
        }
    }
    maps.add(RangeMap(ranges))
    return maps
}

private fun partOne(seeds: List<Long>, rangeMaps: List<RangeMap>): Long {
    var lowest: Long? = null
    for (seed in seeds) {
        var cur = seed
        for (rangeMap in rangeMaps) {
            cur = rangeMap.mapValue(cur)
        }
        if (lowest == null || cur < lowest) {
            lowest = cur
        }
    }
    return lowest!!
}

private fun partTwo(seeds: List<LongRange>, rangeMaps: List<RangeMap>): Long {
    var lowest: Long? = null

    for ((index, range) in seeds.withIndex()) {
        println("Processing $range")

        for (seed in range) {
            var cur = seed
            for (rangeMap in rangeMaps) {
                cur = rangeMap.mapValue(cur)
            }
            if (lowest == null || cur < lowest) {
                lowest = cur
            }
        }

        println("Done ${index + 1}/${seeds.size}. Lowest $lowest")
    }

    return lowest!!
}

fun main() {
    val input = readFileAsList("05/input").map(String::trim).filter(String::isNotEmpty)
    val maps = getRangeMaps(input)
    println("Part 1: ${partOne(getSeeds(input[0]), maps)}")
    println("Part 2: ${partTwo(getSeedRanges(input[0]), maps)}")
}
