import 'dart:collection';

import 'package:esotranspiler/esotranspiler.dart';
import 'package:test/test.dart';

void main() {
  TagSystem testProgram = (
    m: 3,
    nA: 2,
    p: {
      1: [2],
      2: [1, 1],
    },
  );
  group('tag', () {
    test('tag1', () {
      expect((TagSystemState(testProgram, Queue.of([2, 2, 2]))..runToCompletion()).word.toList(), [1, 1]);
    });
    test('tag2', () {
      expect((TagSystemState(testProgram, Queue.of([2, 2, 2, 2]))..runToCompletion()).word.toList(), [1, 1]);
    });
    test('tag3', () {
      expect((TagSystemState(testProgram, Queue.of([2, 2, 2, 2, 2]))..runToCompletion()).word.toList(), [2]);
    });
    test('tag4', () {
      expect((TagSystemState(testProgram, Queue.of([2, 2, 2, 2, 2, 2]))..runToCompletion()).word.toList(), [1, 2]);
    });
  });
}
