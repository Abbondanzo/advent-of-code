import '../utils.dart';
import './parse.dart';

class Group {
  final int xStart;
  final int xEnd;
  final int yStart;
  final int yEnd;
  final int zStart;
  final int zEnd;

  Group(this.xStart, this.xEnd, this.yStart, this.yEnd, this.zStart, this.zEnd);

  bool intersects(Group other) {
    return xStart <= other.xEnd &&
        other.xStart <= xEnd &&
        yStart <= other.yEnd &&
        other.yStart <= yEnd &&
        zStart <= other.zEnd &&
        other.zStart <= zEnd;
  }

  List<Group> carve(Group other) {
    List<Group> subgroups = [];

    // Carve from -X
    int newXStart = xStart;
    if (xStart < other.xStart) {
      newXStart = other.xStart;
      final negXGroup =
          Group(xStart, other.xStart - 1, yStart, yEnd, zStart, zEnd);
      subgroups.add(negXGroup);
    }

    // Carve from +X
    int newXEnd = xEnd;
    if (xEnd > other.xEnd) {
      newXEnd = other.xEnd;
      final posXGroup = Group(other.xEnd + 1, xEnd, yStart, yEnd, zStart, zEnd);
      subgroups.add(posXGroup);
    }

    // Carve from -Y
    int newYStart = yStart;
    if (yStart < other.yStart) {
      newYStart = other.yStart;
      final negYGroup =
          Group(newXStart, newXEnd, yStart, other.yStart - 1, zStart, zEnd);
      subgroups.add(negYGroup);
    }

    // Carve from +Y
    int newYEnd = yEnd;
    if (yEnd > other.yEnd) {
      newYEnd = other.yEnd;
      final posYGroup =
          Group(newXStart, newXEnd, other.yEnd + 1, yEnd, zStart, zEnd);
      subgroups.add(posYGroup);
    }

    // Carve from -Z
    if (zStart < other.zStart) {
      final negZGroup = Group(
          newXStart, newXEnd, newYStart, newYEnd, zStart, other.zStart - 1);
      subgroups.add(negZGroup);
    }

    // Carve from +Z
    if (zEnd > other.zEnd) {
      final posZGroup =
          Group(newXStart, newXEnd, newYStart, newYEnd, other.zEnd + 1, zEnd);
      subgroups.add(posZGroup);
    }

    return subgroups;
  }

  int get numCubes {
    return (xEnd - xStart + 1) * (yEnd - yStart + 1) * (zEnd - zStart + 1);
  }

  @override
  String toString() {
    return 'Group($xStart..$xEnd,$yStart..$yEnd,$zStart..$zEnd)';
  }
}

void main() async {
  final input = await parseInput('22/input');

  // final groupA = Group(0, 3, 0, 3, 0, 3);
  // final groupB = Group(1, 2, 1, 2, 1, 2);
  // print(groupA.carve(groupB).map((e) => e.numCubes));
  // print(groupA.numCubes);
  // print(groupB.numCubes);
  // print(groupB.carve(groupA));
  // final groupC = Group(2, 4, 2, 4, 2, 4);

  final List<Group> groupList = [];

  void handleStep(Step step) {
    final group = Group(step.coords[0], step.coords[1], step.coords[2],
        step.coords[3], step.coords[4], step.coords[5]);
    if (step.turnOn) {
      groupList.add(group);
    } else {
      final intersectGroups =
          groupList.where((onGroup) => onGroup.intersects(group)).toList();
      intersectGroups.forEach((onGroup) {
        groupList.remove(onGroup);
        groupList.addAll(onGroup.carve(group));
      });
    }
  }

  input.initializationProcedure.forEach(handleStep);
  input.outsideProcedure.forEach(handleStep);

  int getTotalCubes() {
    int output = 0;
    final copiedList = List.from(groupList);

    while (copiedList.isNotEmpty) {
      final Group currentGroup = copiedList.removeAt(0);
      output += currentGroup.numCubes;

      final intersectGroups = copiedList
          .where((otherGroup) => otherGroup.intersects(currentGroup))
          .toList();
      intersectGroups.forEach((otherGroup) {
        copiedList.remove(otherGroup);
        copiedList.addAll(otherGroup.carve(currentGroup));
      });
    }

    return output;
  }

  final finalCubeCount = getTotalCubes();
  print(finalCubeCount);
}
