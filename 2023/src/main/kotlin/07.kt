import Utils.readFileAsList

private enum class HandType(val order: Int) {
    FIVE_OF_A_KIND(0),
    FOUR_OF_A_KIND(1),
    FULL_HOUSE(2),
    THREE_OF_A_KIND(3),
    TWO_PAIR(4),
    ONE_PAIR(5),
    HIGH_CARD(6),
}

private data class Hand(
    val cards: List<Char>,
    val bid: Int,
    val withJoker: Boolean,
) : Comparable<Hand> {

    private val handType by lazy {
        val cardMap = cards.groupingBy { it }.eachCount().toMutableMap()
        if (withJoker && cardMap.containsKey('J') && cardMap.keys.size > 1) {
            val remainingEntries = cardMap.entries.filter { it.key != 'J' }.sortedBy { it.value }
            val lastEntry = remainingEntries.last()
            cardMap[lastEntry.key] = lastEntry.value + cardMap['J']!!
            cardMap.remove('J')
        }
        when (true) {
            cardMap.containsValue(5) -> HandType.FIVE_OF_A_KIND
            cardMap.containsValue(4) -> HandType.FOUR_OF_A_KIND
            cardMap.containsValue(3) -> {
                if (cardMap.containsValue(2)) HandType.FULL_HOUSE else HandType.THREE_OF_A_KIND
            }

            else -> {
                val pairs = cardMap.values.count { it == 2 }
                when (pairs) {
                    2 -> HandType.TWO_PAIR
                    1 -> HandType.ONE_PAIR
                    else -> HandType.HIGH_CARD
                }
            }
        }
    }

    override fun compareTo(other: Hand): Int {
        assert(withJoker == other.withJoker)
        if (other.handType.order < handType.order) {
            return -1
        } else if (other.handType.order > handType.order) {
            return 1
        } else {
            for ((index, char) in cards.withIndex()) {
                val handIndex = if (withJoker) JOKER_HAND else HAND
                val thisCard = handIndex.indexOf(char)
                val otherCard = handIndex.indexOf(other.cards[index])
                if (thisCard < otherCard) {
                    return -1
                } else if (thisCard > otherCard) {
                    return 1
                }
            }
        }
        return 0
    }

    companion object {
        private const val HAND = "23456789TJQKA"
        private const val JOKER_HAND = "J23456789TQKA"
    }
}

private fun partOne(input: List<String>): Int {
    val hands = input.map { line ->
        val chunks = line.split(" ")
        assert(chunks.size >= 2)
        val cards = chunks[0].toList()
        val bid = chunks[1].toInt()
        Hand(cards, bid, false)
    }.sorted()
    var total = 0
    for ((index, hand) in hands.withIndex()) {
        total += (index + 1) * hand.bid
    }
    return total
}

private fun partTwo(input: List<String>): Long {
    val hands = input.map { line ->
        val chunks = line.split(" ")
        assert(chunks.size >= 2)
        val cards = chunks[0].toList()
        val bid = chunks[1].toInt()
        Hand(cards, bid, true)
    }.sorted()
    var total = 0L
    for ((index, hand) in hands.withIndex()) {
        total += (index + 1) * hand.bid
    }
    return total
}

fun main() {
    val input = readFileAsList("07/input").map(String::trim).filter(String::isNotEmpty)
    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
