import 'dart:collection';
import 'dart:math';

import '../utils.dart';

abstract class Packet {
  final int packetVersion;
  final int packetTypeID;

  Packet(this.packetVersion, this.packetTypeID);

  int getValue();
}

class LiteralPacket extends Packet {
  final int literalValue;

  LiteralPacket(int packetVersion, this.literalValue) : super(packetVersion, 4);

  int getValue() {
    return literalValue;
  }
}

class OperatorPacket extends Packet {
  final List<Packet> subpackets;

  OperatorPacket(int packetVersion, int packetTypeID, this.subpackets)
      : super(packetVersion, packetTypeID);

  int getValue() {
    switch (packetTypeID) {

      /// sum
      case 0:
        return subpackets.fold(0, (acc, sb) => acc + sb.getValue());

      /// product
      case 1:
        return subpackets.fold(1, (acc, sb) => acc * sb.getValue());

      /// minimum
      case 2:
        return subpackets.fold<int?>(null, (previousValue, element) {
              return previousValue == null
                  ? element.getValue()
                  : min(previousValue, element.getValue());
            }) ??
            0;

      /// maximum
      case 3:
        return subpackets.fold<int?>(null, (previousValue, element) {
              return previousValue == null
                  ? element.getValue()
                  : max(previousValue, element.getValue());
            }) ??
            0;

      /// greater than
      case 5:
        assert(subpackets.length == 2);
        return subpackets[0].getValue() > subpackets[1].getValue() ? 1 : 0;

      /// less than
      case 6:
        assert(subpackets.length == 2);
        return subpackets[0].getValue() < subpackets[1].getValue() ? 1 : 0;

      /// equal to
      case 7:
        assert(subpackets.length == 2);
        return subpackets[0].getValue() == subpackets[1].getValue() ? 1 : 0;

      default:
        throw Error();
    }
  }
}

class InlineOperatorPacket extends OperatorPacket {
  final int expectedLength;

  InlineOperatorPacket(int packetVersion, int packetTypeID,
      List<Packet> subpackets, this.expectedLength)
      : super(packetVersion, packetTypeID, subpackets);
}

Future<String> parseInput(String path) async {
  final fileDescriptor = readFile(path);
  final lines = await fileDescriptor.toList();
  assert(lines.length == 1);
  String output = '';
  for (int index = 0; index < lines[0].length; index++) {
    final hexDigit = lines[0].substring(index, index + 1);
    final realInt = int.parse(hexDigit, radix: 16);
    final binaryString = realInt.toRadixString(2);
    output += ('0' * (4 - binaryString.length)) + binaryString;
  }
  return output;
}

List<Packet> processPacket(String binaryInput) {
  int cursor = 0;

  final List<Packet> packets = [];
  final inlinePacketQueue = Queue<InlineOperatorPacket>();

  void addPacket(Packet packet) {
    if (inlinePacketQueue.isEmpty) {
      packets.add(packet);
    } else {
      final currentInlineOperator = inlinePacketQueue.removeLast();
      currentInlineOperator.subpackets.add(packet);
      if (currentInlineOperator.subpackets.length <
          currentInlineOperator.expectedLength) {
        inlinePacketQueue.addLast(currentInlineOperator);
      } else {
        addPacket(currentInlineOperator);
      }
    }
  }

  while (cursor < binaryInput.length) {
    /// Carve N characters using the cursor
    String carve(int carveLength) {
      final strToReturn = binaryInput.substring(cursor, cursor + carveLength);
      cursor += carveLength;
      return strToReturn;
    }

    int readHeaderValue() {
      return int.parse(carve(3), radix: 2);
    }

    /// Can't read a full header, break out
    if (cursor + 6 > binaryInput.length) {
      break;
    }

    final packetVersion = readHeaderValue();
    final packetTypeId = readHeaderValue();

    final isLiteral = packetTypeId == 4;

    if (isLiteral) {
      /// Return early if no groups can be read
      if (cursor + 5 > binaryInput.length) {
        break;
      }

      String literalBinary = '';
      String carved = carve(5);
      while (true) {
        literalBinary += carved.substring(1);

        /// Exit on the last group type
        if (carved[0] == '0') {
          break;
        }

        /// Drop the last few bits
        if (cursor + 5 > binaryInput.length) {
          break;
        }

        /// Otherwise, keep carving
        carved = carve(5);
      }

      final literalValue = int.parse(literalBinary, radix: 2);
      addPacket(LiteralPacket(packetVersion, literalValue));
    }

    /// Parse operators!
    else {
      /// Return early if no operators can be read
      if (cursor + 12 > binaryInput.length) {
        break;
      }

      final lengthTypeID = carve(1);
      final is15BitType = lengthTypeID == '0';

      if (is15BitType) {
        final lengthBinary = carve(15);
        final subpacketLength = int.parse(lengthBinary, radix: 2);
        final subpacketBinary = carve(subpacketLength);
        final subpackets = processPacket(subpacketBinary);
        addPacket(OperatorPacket(packetVersion, packetTypeId, subpackets));
      } else {
        final numSubPacketsBinary = carve(11);
        final numSubPackets = int.parse(numSubPacketsBinary, radix: 2);
        inlinePacketQueue.addLast(InlineOperatorPacket(
            packetVersion, packetTypeId, [], numSubPackets));
      }
    }
  }

  while (inlinePacketQueue.isNotEmpty) {
    addPacket(inlinePacketQueue.removeLast());
  }

  return packets;
}

/// What do you get if you add up the version numbers in all packets?
int addAllVersionNumbers(List<Packet> packets) {
  int versionNumTotal = 0;
  packets.forEach((packet) {
    versionNumTotal += packet.packetVersion;
    if (packet is OperatorPacket) {
      versionNumTotal += addAllVersionNumbers(packet.subpackets);
    }
  });
  return versionNumTotal;
}

void main() async {
  final input = await parseInput('16/input');
  final packets = processPacket(input);
  print(addAllVersionNumbers(packets));
}
