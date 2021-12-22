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
}

void main() async {
  final input = await parseInput('22/demo2');

  final List<Group> groupList = [];
  input.initializationProcedure.forEach((step) {
    final group = Group(step.coords[0], step.coords[1], step.coords[2],
        step.coords[3], step.coords[4], step.coords[5]);
    if (step.turnOn) {
      groupList.add(group);
    } else {
      print(groupList.where((element) => element.intersects(group)).length);
    }
  });
  input.outsideProcedure.forEach((step) {
    final group = Group(step.coords[0], step.coords[1], step.coords[2],
        step.coords[3], step.coords[4], step.coords[5]);
    if (step.turnOn) {
      groupList.add(group);
    } else {
      print(groupList.where((element) => element.intersects(group)).length);
    }
  });
}
