import 'package:collection/collection.dart';

final ROOM_IDX_MAP = Map<String, List<int>>.fromEntries([
  MapEntry('A', [0, 1]),
  MapEntry('B', [2, 3]),
  MapEntry('C', [4, 5]),
  MapEntry('D', [6, 7])
]);
final INV_ROOM_IDX_MAP = Map<int, String>.fromEntries([
  MapEntry(0, 'A'),
  MapEntry(1, 'A'),
  MapEntry(2, 'B'),
  MapEntry(3, 'B'),
  MapEntry(4, 'C'),
  MapEntry(5, 'C'),
  MapEntry(6, 'D'),
  MapEntry(7, 'D'),
]);
final ROOM_HALLWAY_MAP = Map<String, int>.fromEntries(
    [MapEntry('A', 2), MapEntry('B', 4), MapEntry('C', 6), MapEntry('D', 8)]);
final STEP_SCALE = Map<String, int>.fromEntries([
  MapEntry('A', 1),
  MapEntry('B', 10),
  MapEntry('C', 100),
  MapEntry('D', 1000)
]);
final List<int> ILLEGAL_HALLWAY_IDX = [2, 4, 6, 8];

/// Game positions
/// ```
/// #############
/// #0123456789A# <-- Hallway [11]
/// ###0#2#4#6### <-- Rooms [8]
///   #1#3#5#7#
///   #########
/// ```
///
/// Where `2`, `4`, `6`, and `8` are illegal hallway positions
class GameState {
  final List<String?> hallway;
  final List<String?> rooms;

  GameState(this.hallway, this.rooms);

  Map<int, List<GameState>> nextPositions() {
    final nextPositions = Map<int, List<GameState>>();

    /// First, check hallway if any can move into room
    hallway.asMap().forEach((hallwayPos, element) {
      if (element != null &&
          _isRoomAvailable(element) &&
          _isHallwayOpenToRoom(hallwayPos, element)) {
        final stepsToNextState = _stepsToRoom(hallwayPos, element);
        final nextRooms = List<String?>.from(rooms);
        nextRooms[_openRoomIndex(element)] = element;
        final nextHallway = List<String?>.from(hallway);
        nextHallway[hallwayPos] = null;
        final nextGameState = GameState(nextHallway, nextRooms);

        nextPositions.update(stepsToNextState, (value) {
          value.add(nextGameState);
          return value;
        }, ifAbsent: () => [nextGameState]);
      }
    });

    /// Then, check if any in a room need to move to hallway
    for (int i = 0; i < rooms.length * 2; i += 2) {
      /// Read from top of rooms to bottom (i.e. 0, 2, 4, 6, 1, 3, 5, 7)
      final readIndex = i >= rooms.length ? (i % rooms.length) + 1 : i;
      final type = rooms[readIndex];
      if (type != null &&
          (!_isInRoom(readIndex) || !_isRoomWellFormed(readIndex))) {
        final openPositions = _getOpenHallwayPositions(readIndex);
        openPositions.forEach((openHallwayPos) {
          final scale = STEP_SCALE[type]!;
          final nextSteps = _stepsToHallway(readIndex, openHallwayPos) * scale;
          final nextRooms = List<String?>.from(rooms);
          nextRooms[readIndex] = null;
          final nextHallway = List<String?>.from(hallway);
          nextHallway[openHallwayPos] = type;

          final nextGameState = GameState(nextHallway, nextRooms);

          nextPositions.update(nextSteps, (value) {
            value.add(nextGameState);
            return value;
          }, ifAbsent: () => [nextGameState]);
        });
      }
    }

    return nextPositions;
  }

  // ==================
  // Room -> Hallway
  // ==================

  bool _isInRoom(int roomIndex) {
    final element = rooms[roomIndex];
    if (element == null) {
      throw Error();
    }
    return ROOM_IDX_MAP[element]!.contains(roomIndex);
  }

  bool _isRoomWellFormed(int roomIndex) {
    final roomType = ROOM_IDX_MAP.entries
        .firstWhere((entry) => entry.value.contains(roomIndex))
        .key;
    return ROOM_IDX_MAP[roomType]!
        .every((idx) => rooms[idx] == null || rooms[idx] == roomType);
  }

  List<int> _getOpenHallwayPositions(int roomIndex) {
    /// Check above
    if (roomIndex % 2 == 1 && rooms[roomIndex] != null) {
      return [];
    }
    final roomType = INV_ROOM_IDX_MAP[roomIndex]!;
    final roomOpenIdx = ROOM_HALLWAY_MAP[roomType]!;
    final List<int> availableIndices = [];

    /// Iterate left
    int left = roomOpenIdx;
    while (left >= 0) {
      if (ILLEGAL_HALLWAY_IDX.contains(left)) {
        left--;
      } else if (hallway[left] == null) {
        availableIndices.add(left);
        left--;
      } else {
        break;
      }
    }

    /// Iterate right
    int right = roomOpenIdx;
    while (right < hallway.length) {
      if (ILLEGAL_HALLWAY_IDX.contains(right)) {
        right++;
      } else if (hallway[right] == null) {
        availableIndices.add(right);
        right++;
      } else {
        break;
      }
    }

    return availableIndices;
  }

  int _stepsToHallway(int roomIndex, int hallwayPos) {
    final stepsToHallway = roomIndex % 2 == 1 ? 2 : 1;
    final roomType = INV_ROOM_IDX_MAP[roomIndex]!;
    final roomOpenIdx = ROOM_HALLWAY_MAP[roomType]!;
    return (hallwayPos - roomOpenIdx).abs() + stepsToHallway;
  }

  // ==================
  // Hallway -> Room
  // ==================

  bool _isRoomAvailable(String type) {
    final indexes = ROOM_IDX_MAP[type]!;
    return rooms
        .sublist(indexes[0], indexes[1] + 1)
        .every((e) => e == null || e == type);
  }

  bool _isHallwayOpenToRoom(int hallwayPos, String type) {
    final roomOpenIdx = ROOM_HALLWAY_MAP[type]!;
    if (hallwayPos < roomOpenIdx) {
      return hallway
          .sublist(hallwayPos + 1, roomOpenIdx + 1)
          .every((e) => e == null);
    } else {
      return hallway.sublist(roomOpenIdx, hallwayPos).every((e) => e == null);
    }
  }

  int _stepsToRoom(int hallwayPos, String type) {
    final distanceToOpen = (hallwayPos - ROOM_HALLWAY_MAP[type]!).abs();
    final roomTop = ROOM_IDX_MAP[type]![0];

    /// Room top should always be empty
    if (rooms[roomTop] != null) {
      throw Error();
    }

    final stepsDown = ((rooms[roomTop + 1] == null) ? 2 : 1);
    return distanceToOpen + stepsDown;
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

  @override
  String toString() {
    final hallwayStr = hallway.map((e) => e == null ? '.' : e).join('');
    final roomChars = rooms.map((e) => e == null ? '.' : e).toList();
    return '''
#############
#$hallwayStr#
###${roomChars[0]}#${roomChars[2]}#${roomChars[4]}#${roomChars[6]}#
  #${roomChars[1]}#${roomChars[3]}#${roomChars[5]}#${roomChars[7]}#
  #########
    ''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!(other is GameState) || runtimeType != other.runtimeType) return false;
    final eq = ListEquality().equals;
    return eq(hallway, other.hallway) && eq(rooms, other.rooms);
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ hallway.hashCode ^ rooms.hashCode;
  }
}

void main() {
  final startGameState = GameState(
      List.filled(11, null), ['B', 'A', 'C', 'D', 'B', 'C', 'D', 'A']);

  final solutionMap = Map<GameState, int>();

  final winningGameState = GameState(
      List.filled(11, null), ['A', 'A', 'B', 'B', 'C', 'C', 'D', 'D']);
  solutionMap[winningGameState] = 0;

  final step2 = GameState(List.filled(11, null)..[3] = 'B',
      ['B', 'A', 'C', 'D', null, 'C', 'D', 'A']);
  final step3 = GameState(
      List.filled(11, null)
        ..[3] = 'B'
        ..[5] = 'C',
      ['B', 'A', null, 'D', null, 'C', 'D', 'A']);

  final NO_STEPS = -1;

  int getCheapestSolution(GameState gameState) {
    if (solutionMap[gameState] == null) {
      int? cheapestSteps = null;

      gameState.nextPositions().entries.forEach((entry) {
        final stepsToNextState = entry.key;
        entry.value.forEach((nextGameState) {
          final nextSolution = getCheapestSolution(nextGameState);

          if (nextSolution != NO_STEPS) {
            final stepsToSolution = stepsToNextState + nextSolution;
            if (cheapestSteps == null || stepsToSolution < cheapestSteps!) {
              cheapestSteps = stepsToSolution;
            }
          }
        });
      });
      solutionMap[gameState] = cheapestSteps ?? NO_STEPS;
    }
    return solutionMap[gameState]!;
  }

  final result = getCheapestSolution(startGameState);
  print(result);
}
