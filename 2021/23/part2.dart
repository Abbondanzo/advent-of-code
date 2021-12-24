import 'package:collection/collection.dart';
import '../utils.dart';

final ROOM_IDX_MAP = Map<String, List<int>>.fromEntries([
  MapEntry('A', [0, 1, 2, 3]),
  MapEntry('B', [4, 5, 6, 7]),
  MapEntry('C', [8, 9, 10, 11]),
  MapEntry('D', [12, 13, 14, 15])
]);
final INV_ROOM_IDX_MAP = Map<int, String>.fromEntries([
  MapEntry(0, 'A'),
  MapEntry(1, 'A'),
  MapEntry(2, 'A'),
  MapEntry(3, 'A'),
  MapEntry(4, 'B'),
  MapEntry(5, 'B'),
  MapEntry(6, 'B'),
  MapEntry(7, 'B'),
  MapEntry(8, 'C'),
  MapEntry(9, 'C'),
  MapEntry(10, 'C'),
  MapEntry(11, 'C'),
  MapEntry(12, 'D'),
  MapEntry(13, 'D'),
  MapEntry(14, 'D'),
  MapEntry(15, 'D'),
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
/// ###0#4#8#C### <-- Rooms [16]
///   #1#5#9#D#
///   #2#6#A#E#
///   #3#7#B#F#
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
        final scale = STEP_SCALE[element]!;
        final stepsToNextState = _stepsToRoom(hallwayPos, element) * scale;

        final nextRooms = List<String?>.from(rooms);
        nextRooms[_openRoomIndex(element)] = element;
        final nextHallway = List<String?>.from(hallway);
        nextHallway[hallwayPos] = null;
        final nextGameState = GameState(nextHallway, nextRooms);

        nextPositions.update(stepsToNextState, (value) {
          return [...value, nextGameState];
        }, ifAbsent: () => [nextGameState]);
      }
    });

    /// Then, check if any in a room need to move to hallway
    final roomSize = _roomSize;

    for (int row = 0; row < roomSize; row++) {
      for (int col = 0; col < 4; col++) {
        final readIndex = row + roomSize * col;
        final type = rooms[readIndex];
        if (type != null &&
            (!_isInRoom(readIndex) || !_isRoomWellFormed(readIndex))) {
          final openPositions = _getOpenHallwayPositions(readIndex);
          openPositions.forEach((openHallwayPos) {
            final scale = STEP_SCALE[type]!;
            final stepsToNextState =
                _stepsToHallway(readIndex, openHallwayPos) * scale;
            final nextRooms = List<String?>.from(rooms);
            nextRooms[readIndex] = null;
            final nextHallway = List<String?>.from(hallway);
            nextHallway[openHallwayPos] = type;

            final nextGameState = GameState(nextHallway, nextRooms);

            nextPositions.update(stepsToNextState, (value) {
              return [...value, nextGameState];
            }, ifAbsent: () => [nextGameState]);
          });
        }
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
    final roomType = INV_ROOM_IDX_MAP[roomIndex]!;
    final roomIndices = ROOM_IDX_MAP[roomType]!;
    // Check above current index
    final sublist = roomIndices.sublist(0, roomIndices.indexOf(roomIndex));
    if (sublist.any((idx) => rooms[idx] != null)) {
      return [];
    }
    // roomIndices.
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
    final roomType = INV_ROOM_IDX_MAP[roomIndex]!;
    final stepsToHallway = ROOM_IDX_MAP[roomType]!.indexOf(roomIndex) + 1;
    final roomOpenIdx = ROOM_HALLWAY_MAP[roomType]!;
    return (hallwayPos - roomOpenIdx).abs() + stepsToHallway;
  }

  // ==================
  // Hallway -> Room
  // ==================

  bool _isRoomAvailable(String type) {
    final indexes = ROOM_IDX_MAP[type]!;
    return rooms
        .sublist(indexes[0], indexes[indexes.length - 1] + 1)
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
    final roomIndices = ROOM_IDX_MAP[type]!;
    final roomIndex = roomIndices.lastWhere((idx) => rooms[idx] == null);
    final stepsDown = ROOM_IDX_MAP[type]!.indexOf(roomIndex) + 1;
    return distanceToOpen + stepsDown;
  }

  int _openRoomIndex(String type) {
    final roomIndices = ROOM_IDX_MAP[type]!;
    return roomIndices.lastWhere((idx) => rooms[idx] == null);
  }

  int get _roomSize {
    return (rooms.length / 4).floor();
  }

  @override
  String toString() {
    final hallwayStr = hallway.map((e) => e == null ? '.' : e).join('');
    String takeRow(int rowIndex) {
      return rooms
          .asMap()
          .entries
          .where((entry) => entry.key % _roomSize == rowIndex)
          .toList()
          .map((e) => e.value == null ? '.' : e.value)
          .join('#');
    }

    return '''
#############
#$hallwayStr#
###${takeRow(0)}###
  #${takeRow(1)}#
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
    return runtimeType.hashCode ^ toString().hashCode;
  }
}

void main() {
  // final demoGameState = GameState(List.filled(11, null), [
  //   'B',
  //   'D',
  //   'D',
  //   'A',
  //   'C',
  //   'C',
  //   'B',
  //   'D',
  //   'B',
  //   'B',
  //   'A',
  //   'C',
  //   'D',
  //   'A',
  //   'C',
  //   'A'
  // ]);
  final inputGameState = GameState(List.filled(11, null), [
    'B',
    'D',
    'D',
    'B',
    'A',
    'C',
    'B',
    'C',
    'A',
    'B',
    'A',
    'D',
    'D',
    'A',
    'C',
    'C'
  ]);

  final solutionMap = Map<GameState, Pair<int, List<GameState>>>();

  final winningGameState = GameState(List.filled(11, null), [
    'A',
    'A',
    'A',
    'A',
    'B',
    'B',
    'B',
    'B',
    'C',
    'C',
    'C',
    'C',
    'D',
    'D',
    'D',
    'D'
  ]);

  solutionMap[winningGameState] = Pair(0, [winningGameState]);

  final NO_STEPS = -1;

  Pair<int, List<GameState>> getCheapestSolution(GameState gameState) {
    if (solutionMap[gameState] == null) {
      Pair<int, List<GameState>>? cheapestSteps = null;

      gameState.nextPositions().entries.forEach((entry) {
        final stepsToNextState = entry.key;

        entry.value.forEach((nextGameState) {
          final nextSolution = getCheapestSolution(nextGameState);

          if (nextSolution.first != NO_STEPS) {
            final stepsToSolution = stepsToNextState + nextSolution.first;
            if (cheapestSteps == null ||
                stepsToSolution < cheapestSteps!.first) {
              cheapestSteps = Pair(
                  stepsToSolution, [nextGameState, ...nextSolution.second]);
            }
          }
        });
      });
      solutionMap[gameState] = cheapestSteps ?? Pair(NO_STEPS, [gameState]);
    }
    return solutionMap[gameState]!;
  }

  final result = getCheapestSolution(inputGameState);

  print(result.first);
}
