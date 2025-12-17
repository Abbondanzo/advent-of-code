import Utils.readFileAsList


private object Day03 {

    private fun helper(banks: List<List<Int>>, batterySize: Int): Long {
        var total = 0L
        for (bank in banks) {
            if (bank.size < batterySize) {
                error("Invalid bank size ${bank.size}")
            }
            val digitIndexes = mutableListOf<Int>()
            while (digitIndexes.size < batterySize) {
                var largestIndex = if (digitIndexes.isEmpty()) 0 else digitIndexes.last() + 1
                val remainingCount = batterySize - digitIndexes.size
                for (i in largestIndex..bank.size - remainingCount) {
                    if (bank[i] > bank[largestIndex]) {
                        largestIndex = i
                    }
                }
                digitIndexes.add(largestIndex)
            }
            val digit = digitIndexes.map { bank[it] }.joinToString("").toLong()
            total += digit
        }
        return total
    }

    private fun partOne(banks: List<List<Int>>): Long {
        return helper(banks, 2)
    }

    private fun partTwo(banks: List<List<Int>>): Long {
        return helper(banks, 12)
    }

    fun main() {
        val input = readFileAsList("03/input").filter { it.isNotEmpty() }.map(String::trim)
        val banks = input.map { row -> row.map { char -> char.toString().toInt() } }
        println("Part 1: ${partOne(banks)}")
        println("Part 2: ${partTwo(banks)}")
    }
}

fun main() {
    Day03.main()
}