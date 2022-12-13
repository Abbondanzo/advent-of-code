import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';

import '../utils.dart';

class Node extends Equatable {
  @override
  List<Object?> get props => [];
}

class ItemNode extends Node {
  final int value;

  ItemNode(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() {
    return value.toString();
  }
}

class ListNode extends Node {
  final List<Node> children;

  ListNode(this.children);

  @override
  List<Object?> get props => [children];

  @override
  String toString() {
    return "[${this.children.join(", ")}]";
  }
}

bool? compare(Node left, Node right) {
  if (left is ItemNode && right is ItemNode) {
    if (left.value == right.value) return null;
    return left.value < right.value;
  }
  if (left is ListNode && right is ListNode) {
    for (int i = 0; i < max(left.children.length, right.children.length); i++) {
      if (i >= left.children.length) return true;
      if (i >= right.children.length) return false;
      final itemLeft = left.children[i];
      final itemRight = right.children[i];
      final decision = compare(itemLeft, itemRight);
      if (decision != null) return decision;
    }
    return null;
  }
  if (left is ItemNode) {
    return compare(ListNode([left]), right);
  }
  if (right is ItemNode) {
    return compare(left, ListNode([right]));
  }
  throw Error();
}

Node toNode(dynamic line) {
  if (line is List) {
    return ListNode(line.map((item) => toNode(item)).toList());
  }
  if (line is int) {
    return ItemNode(line);
  }
  throw Error();
}

Future<List<Pair<Node, Node>>> parseInput(String path) async {
  final inputLines = readFile(path);
  final inputLineList = await inputLines.toList();
  final List<Pair<Node, Node>> pairs = [];
  for (int i = 0; i < inputLineList.length; i += 3) {
    final packetA = toNode(jsonDecode(inputLineList[i]));
    final packetB = toNode(jsonDecode(inputLineList[i + 1]));
    pairs.add(Pair(packetA, packetB));
  }
  return pairs;
}
