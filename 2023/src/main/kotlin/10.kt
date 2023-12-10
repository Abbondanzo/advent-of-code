import Utils.readFileAsList

private data class Coordinate(
    val row: Int,
    val column: Int,
) {
    fun getNeighbors(): List<Coordinate> {
        return listOf(
            Coordinate(row - 1, column),
            Coordinate(row + 1, column),
            Coordinate(row, column - 1),
            Coordinate(row, column + 1),
        )
    }
}

private fun getStartingPosition(input: List<List<Char>>): Coordinate {
    for (rowIndex in input.indices) {
        val row = input[rowIndex]
        for (colIndex in row.indices) {
            if (row[colIndex] == 'S') {
                return Coordinate(rowIndex, colIndex)
            }
        }
    }
    error("Input does not contain a starting position")
}

private data class Edge(
    val x: Int,
    val y: Int
) {
    init {
        assert(x == 0 || y == 0)
    }
}

private operator fun Coordinate.plus(edge: Edge): Coordinate {
    return Coordinate(this.row + edge.y, this.column + edge.x)
}

private fun getStartingEdges(startingPosition: Coordinate, input: List<List<Char>>): Pair<Edge, Edge> {
    val maybeEdges = mutableListOf<Edge>()
    // North
    if (startingPosition.row > 0) {
        val char = input[startingPosition.row - 1][startingPosition.column]
        if (arrayOf('F', '7', '|').contains(char)) {
            maybeEdges.add(Edge(0, -1))
        }
    }
    // South
    if (startingPosition.row < input.size) {
        val char = input[startingPosition.row + 1][startingPosition.column]
        if (arrayOf('L', 'J', '|').contains(char)) {
            maybeEdges.add(Edge(0, 1))
        }
    }
    // West
    if (startingPosition.column > 0) {
        val char = input[startingPosition.row][startingPosition.column - 1]
        if (arrayOf('F', 'L', '-').contains(char)) {
            maybeEdges.add(Edge(-1, 0))
        }
    }
    // East
    if (startingPosition.column < input[0].size) {
        val char = input[startingPosition.row][startingPosition.column + 1]
        if (arrayOf('J', '7', '-').contains(char)) {
            maybeEdges.add(Edge(1, 0))
        }
    }
    assert(maybeEdges.size == 2)
    return Pair(maybeEdges[0], maybeEdges[1])
}

private fun getNextEdge(input: List<List<Char>>, position: Coordinate, lastEdge: Edge): Edge {
    return when (val char = input[position.row][position.column]) {
        '|' -> {
            assert(lastEdge.x == 0 && lastEdge.y != 0)
            lastEdge
        }

        '-' -> {
            assert(lastEdge.x != 0 && lastEdge.y == 0)
            lastEdge
        }

        'L' -> {
            assert(lastEdge.x == -1 || lastEdge.y == 1)
            if (lastEdge.y == 1) Edge(1, 0) else Edge(0, -1)
        }

        'J' -> {
            assert(lastEdge.x == 1 || lastEdge.y == 1)
            if (lastEdge.y == 1) Edge(-1, 0) else Edge(0, -1)
        }

        '7' -> {
            assert(lastEdge.x == 1 || lastEdge.y == -1)
            if (lastEdge.y == -1) Edge(-1, 0) else Edge(0, 1)
        }

        'F' -> {
            assert(lastEdge.x == -1 || lastEdge.y == -1)
            if (lastEdge.y == -1) Edge(1, 0) else Edge(0, 1)
        }

        else -> {
            error("Unrecognized character $char")
        }
    }
}

private fun getLoop(input: List<List<Char>>): Set<Coordinate> {
    val startingPosition = getStartingPosition(input)
    val edges = getStartingEdges(startingPosition, input)

    val loop = mutableSetOf<Coordinate>()
    var lastEdge = edges.first
    var curCoordinate = startingPosition + lastEdge
    loop.add(curCoordinate)
    while (curCoordinate != startingPosition) {
        val nextEdge = getNextEdge(input, curCoordinate, lastEdge)
        curCoordinate += nextEdge
        lastEdge = nextEdge
        loop.add(curCoordinate)
    }

    return loop
}

private fun partOne(input: List<List<Char>>): Int {
    val loop = getLoop(input)
    return loop.size / 2
}

private fun replaceStartingCharacter(input: List<List<Char>>): List<List<Char>> {
    val startingPosition = getStartingPosition(input)
    val edges = getStartingEdges(startingPosition, input)
    val x = edges.first.x + edges.second.x
    val y = edges.first.y + edges.second.y
    val char = when (true) {
        (edges.first.x == 0 && edges.second.x == 0) -> '|'
        (edges.first.y == 0 && edges.second.y == 0) -> '-'
        (x == 1 && y == 1) -> 'F'
        (x == 1 && y == -1) -> 'L'
        (x == -1 && y == -1) -> 'J'
        (x == -1 && y == 1) -> '7'
        else -> error("Unknown character")
    }
    val mutableInput = input.map { it.toMutableList() }.toMutableList()
    mutableInput[startingPosition.row][startingPosition.column] = char
    return mutableInput
}

private fun buildGroup(position: Coordinate, input: List<List<Char>>, loop: Set<Coordinate>): Set<Coordinate> {
    val group = mutableSetOf<Coordinate>()
    val toScan = mutableListOf(position)
    while (toScan.isNotEmpty()) {
        val pos = toScan.removeFirst()
        group.add(pos)
        val maybeNeighbors = pos.getNeighbors().filter { neighbor ->
            !loop.contains(neighbor)
                    && !group.contains(neighbor)
                    && !toScan.contains(neighbor)
                    && neighbor.row in input.indices
                    && neighbor.column in input[0].indices
        }
        toScan.addAll(maybeNeighbors)
    }
    return group
}

private fun lazyOutsideCheck(position: Coordinate, input: List<List<Char>>, loop: Set<Coordinate>): Boolean {
    fun countIntersection(range: List<Coordinate>, map: Map<Char, Char>, always: Char): Int {
        var count = 0
        var lastChar: Char? = null
        for (c in range) {
            val char = input[c.row][c.column]
            if (char == always) {
                count++
            } else {
                assert(map.containsKey(char))
                lastChar = if (lastChar == null) {
                    char
                } else {
                    if (map[char] != lastChar) {
                        count++
                    }
                    null
                }
            }
        }
        assert(lastChar == null)
        return count
    }

    fun northSouth(range: List<Coordinate>): Int {
        val northSouthMap = mapOf(
            'F' to 'L',
            'L' to 'F',
            '7' to 'J',
            'J' to '7',
        )
        return countIntersection(range, northSouthMap, '-')
    }
    // North
    val pointsNorth = ((position.row - 1)..0)
        .map { Coordinate(it, position.column) }
        .filter { loop.contains(it) && input[it.row][it.column] != '|' }
    val intersectionsNorth = northSouth(pointsNorth)
    if (intersectionsNorth % 2 != 0) {
        return false
    }
    // South
    val pointsSouth = ((position.row + 1)..<input.size)
        .map { Coordinate(it, position.column) }
        .filter { loop.contains(it) && input[it.row][it.column] != '|' }
    val intersectionsSouth = northSouth(pointsSouth)
    if (intersectionsSouth % 2 != 0) {
        return false
    }

    fun eastWest(range: List<Coordinate>): Int {
        val eastWestMap = mapOf(
            'F' to '7',
            '7' to 'F',
            'L' to 'J',
            'J' to 'L',
        )
        return countIntersection(range, eastWestMap, '|')
    }

    // East
    val pointsEast = ((position.column + 1)..<input[0].size)
        .map { Coordinate(position.row, it) }
        .filter { loop.contains(it) && input[it.row][it.column] != '-' }
    val intersectionsEast = eastWest(pointsEast)
    if (intersectionsEast % 2 != 0) {
        return false
    }
    // West
    val pointsWest = ((position.column - 1)..0)
        .map { Coordinate(position.row, it) }
        .filter { loop.contains(it) && input[it.row][it.column] != '-' }
    val intersectionsWest = eastWest(pointsWest)
    return intersectionsWest % 2 == 0
}

private fun scanGroups(input: List<List<Char>>, loop: Set<Coordinate>): Int {
    val visited = mutableSetOf<Coordinate>()
    visited.addAll(loop)
    var insideCount = 0
    for (rowIndex in input.indices) {
        for (colIndex in input[0].indices) {
            val coordinate = Coordinate(rowIndex, colIndex)
            if (!visited.contains(coordinate)) {
                val group = buildGroup(coordinate, input, loop)
                visited.addAll(group)
                val isOutside = group.any { member ->
                    member.row == 0
                            || member.column == 0
                            || member.row == input.size - 1
                            || member.column == input[0].size - 1
                } || lazyOutsideCheck(group.first(), input, loop)
                if (!isOutside) {
                    insideCount += group.size
                }
            }
        }
    }
    return insideCount
}

private fun partTwo(input: List<List<Char>>): Int {
    val loop = getLoop(input)
    val replacedInput = replaceStartingCharacter(input)
    return scanGroups(replacedInput, loop)
}

fun main() {
    val input = readFileAsList("10/input").map(String::trim).filter(String::isNotEmpty)
    val mappedInput = input.map { it.toCharArray().toList() }
    println("Part 1: ${partOne(mappedInput)}")
    println("Part 2: ${partTwo(mappedInput)}")
}
