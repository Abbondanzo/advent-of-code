final ROOM_IDX_MAP = Map<String, List<int>>.fromEntries([
  MapEntry('A', [0, 1]),
  MapEntry('B', [2, 3]),
  MapEntry('C', [4, 5]),
  MapEntry('D', [6, 7])
]);
final ROOM_LR_HALLWAY_MAP = Map<String, List<int>>.fromEntries([
  MapEntry('A', [1, 2]),
  MapEntry('B', [2, 3]),
  MapEntry('C', [3, 4]),
  MapEntry('D', [4, 5])
]);

/// Game positions
/// ```
/// #############
/// #01.2.3.4.56# <-- Hallway [7]
/// ###0#2#4#6### <-- Rooms [8]
///   #1#3#5#7#
///   #########
/// ```
class GameState {
  final List<String?> hallway;
  final List<String?> rooms;
  final int steps;

  GameState(this.hallway, this.rooms, this.steps);

  List<GameState> nextPositions() {
    final List<GameState> nextPositions = [];

    /// First, check hallway if any can move into room
    hallway.asMap().forEach((hallwayPos, element) {
      if (element != null &&
          _isRoomAvailable(element) &&
          _isHallwayOpenToRoom(hallwayPos, element)) {
        final nextSteps = _stepsToRoom(hallwayPos, element);
        final nextRooms = List<String?>.from(rooms);
        nextRooms[_openRoomIndex(element)] = element;
        final nextHallway = List<String?>.from(hallway);
        nextHallway[hallwayPos] = null;
        nextPositions.add(GameState(hallway, nextRooms, steps + nextSteps));
      }
    });

    /// Then, check if any in a room need to move to hallway
    for (int i = 0; i < rooms.length * 2; i += 2) {
      /// Read from top of rooms to bottom (i.e. 0, 2, 4, 6, 1, 3, 5, 7)
      final readIndex = i >= rooms.length ? (i % rooms.length) + 1 : i;
      if (rooms[readIndex] != null && !_isInRoom(readIndex)) {
        print(rooms[readIndex]);
      }
    }

    return nextPositions;
  }

  bool _isInRoom(int roomIndex) {
    final element = rooms[roomIndex];
    if (element == null) {
      throw Error();
    }
    return ROOM_IDX_MAP[element]!.contains(roomIndex);
  }

  bool _isRoomAvailable(String type) {
    final indexes = ROOM_IDX_MAP[type]!;
    return rooms
        .sublist(indexes[0], indexes[1] + 1)
        .every((e) => e == null || e == 'type');
  }

  bool _isHallwayOpenToRoom(int hallwayPos, String type) {
    bool checkLR(int left, int right) {
      if (hallwayPos == left || hallwayPos == right) {
        return true;
      } else if (hallwayPos < left) {
        return hallway.sublist(hallwayPos + 1, left).every((e) => e == null);
      } else {
        return hallway.sublist(right, hallwayPos).every((e) => e == null);
      }
    }

    final l = ROOM_LR_HALLWAY_MAP[type]![0];
    final r = ROOM_LR_HALLWAY_MAP[type]![1];
    return checkLR(l, r);
  }

  int _stepsToRoom(int hallwayPos, String type) {
    int checkLRT(int left, int right, int roomTop) {
      /// Room top should always be empty
      if (rooms[roomTop] != null) {
        throw Error();
      }

      final stepsDown = ((rooms[roomTop + 1] == null) ? 2 : 1);

      if (hallwayPos == left || hallwayPos == right) {
        return 1 + stepsDown;
      } else if (hallwayPos < left) {
        return (2 * left) - hallwayPos + stepsDown;
      } else {
        return hallwayPos - ((6 - right) * 2) + stepsDown;
      }
    }

    switch (type) {
      case 'A':
        return checkLRT(1, 2, 0);
      case 'B':
        return checkLRT(2, 3, 2) * 10;
      case 'C':
        return checkLRT(3, 4, 4) * 100;
      case 'D':
        return checkLRT(4, 5, 6) * 1000;
      default:
        throw Error();
    }
  }

  int _openRoomIndex(String type) {
    int checkRoomTop(int roomTop) {
      /// Room top should always be empty
      if (rooms[roomTop] != null) {
        throw Error();
      }
      return rooms[roomTop + 1] == null ? roomTop + 1 : roomTop;
    }

    switch (type) {
      case 'A':
        return checkRoomTop(0);
      case 'B':
        return checkRoomTop(2);
      case 'C':
        return checkRoomTop(4);
      case 'D':
        return checkRoomTop(6);
      default:
        throw Error();
    }
  }
}

void main() {
  final startGameState = GameState(List.filled(7, null),
      List.unmodifiable(['B', 'A', 'C', 'D', 'B', 'C', 'D', 'A']), 0);

  print(startGameState.nextPositions());
}
