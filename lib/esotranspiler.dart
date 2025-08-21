import 'dart:collection';

/// see https://esolangs.org/wiki/Tag_system
/// this is the version with no halting symbol
/// [nA] = # of characters in alphabet
/// alphabet is 0 through [nA]-1
/// p maps each int in alphabet -> word (a list of ints in alphabet)
typedef TagSystem = ({int m, int nA, Map<int, List<int>> p});

abstract class EsolangState {
  bool get isDone;
  void step();
}

class TagSystemState extends EsolangState {
  final TagSystem system;
  Queue<int> word;

  @override
  bool get isDone => word.length < system.m;
  @override
  void step() {
    int command = word.first;
    int i = 0;
    while (i < system.m) {
      word.removeFirst();
      i++;
    }
    word.addAll(system.p[command]!);
  }

  void runToCompletion() {
    while (!isDone) {
      step();
    }
  }

  TagSystemState(this.system, this.word);
}
