import 'dart:collection';
import 'dart:math';

import 'package:esotranspiler/esotranspiler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esolang Transpiler',
      theme: ThemeData.dark(),
      home: TagSystemCreator(),
    );
  }
}

class TagSystemCreator extends StatefulWidget {
  const TagSystemCreator({super.key});

  @override
  State<TagSystemCreator> createState() => _TagSystemCreatorState();
}

class _TagSystemCreatorState extends State<TagSystemCreator> {
  int? m;
  int nA = 0;
  Map<int, List<int>> p = {};
  List<int> initialWord = [];
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnchorWidget(
            href: Uri.parse('https://esolangs.org/wiki/Tag_system'),
            'What is a tag system?',
          ),
          Text('Words are represented by a sequence of numbers separated by commas.'),
          OutlinedButton(
            onPressed: (m == null && nA > 0 && p.entries.length == nA)
                ? null
                : () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TagSystemRunner((m: m!, nA: nA, p: p), initialWord),
                      ),
                    );
                  },
            child: Text('Run system'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('# of characters to remove each step: '),
              Container(
                width: 50,
                child: TextField(
                  onChanged: (value) => setState(() {
                    m = int.tryParse(value);
                  }),
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                ),
              ),
            ],
          ),
          Text.rich(
            TextSpan(
              text: 'Initial word: ',
              children: [
                WidgetSpan(
                  child: WordFieldWidget(
                    update: (value) => initialWord = value,
                    nA: nA,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 1; i <= nA; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: '$i =>',
                    children: [
                      WidgetSpan(
                        child: WordFieldWidget(
                          update: (value) => p[i] = value,
                          nA: nA,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    int j = i + 1;
                    while (j <= nA) {
                      List<int>? rule = p[j];
                      if (rule != null) {
                        p[j - 1] = rule;
                      }
                      j++;
                    }
                    p.remove(nA);
                    nA--;
                  }),
                  icon: Icon(Icons.remove),
                ),
              ],
            ),
          IconButton(
            onPressed: () => setState(() {
              nA++;
            }),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class AnchorWidget extends StatefulWidget {
  const AnchorWidget(this.content, {super.key, required this.href});

  final Uri href;
  final String content;

  @override
  State<AnchorWidget> createState() => _AnchorWidgetState();
}

class _AnchorWidgetState extends State<AnchorWidget> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => launchUrl(widget.href),
      child: Text(
        widget.content,
        style: TextStyle(
          color: Colors.lightBlue,
          decoration: hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: Colors.lightBlue
        ),
      ),
      style: ButtonStyle(),
      onHover: (final bool hovered) {
        setState(() {
          this.hovered = hovered;
        });
      },
    );
  }
}

class WordFieldWidget extends StatelessWidget {
  const WordFieldWidget({super.key, required this.update, required this.nA});

  final void Function(List<int>) update;
  final int nA;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        onChanged: (text) {
          if (text.isEmpty) return;
          if (text.endsWith(',')) {
            text = text.substring(0, text.length - 1);
          }
          update(
            text.split(',').map((e) => max(1, min(nA, int.parse(e)))).toList(),
          );
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
          TextInputFormatter.withFunction((
            TextEditingValue oldValue,
            TextEditingValue newValue,
          ) {
            String text = newValue.text;
            if (text.isEmpty) return newValue;
            if (text.endsWith(',')) {
              text = text.substring(0, text.length - 1);
            }
            List<String> parsedValue = text.split(',');
            if (parsedValue.any((e) {
              int? num = int.tryParse(e);
              if (num == null || (num < 1 || num > nA)) {
                return true;
              }
              return false;
            })) {
              String oldText = oldValue.text;
              if (oldText.isEmpty) return oldValue;
              if (oldText.endsWith(',')) {
                oldText = oldText.substring(0, oldText.length - 1);
              }
              List<String> parsedOldValue = oldText.split(',');
              if (parsedOldValue.any((e) {
                int? num = int.tryParse(e);
                if (num == null || (num < 1 || num > nA)) {
                  return true;
                }
                return false;
              })) {
                print('ov: ${oldValue.text} - $parsedOldValue');
                String text =
                    parsedValue
                        .map((e) {
                          int? n = int.tryParse(e);
                          if (n == null) return 0;
                          return n < 1
                              ? 1
                              : n > nA
                              ? nA
                              : n;
                        })
                        .join(',') +
                    (newValue.text.endsWith(',') ? ',' : '');
                return TextEditingValue(
                  selection: TextSelection(
                    baseOffset: min(oldValue.selection.baseOffset, text.length),
                    extentOffset: min(
                      oldValue.selection.extentOffset,
                      text.length,
                    ),
                  ),
                  text: text,
                );
              }
              return oldValue;
            }
            return newValue;
          }),
        ],
      ),
    );
  }
}

class TagSystemRunner extends StatefulWidget {
  const TagSystemRunner(this.tagSystem, this.initialWord, {super.key});
  final TagSystem tagSystem;
  final List<int> initialWord;

  @override
  State<TagSystemRunner> createState() => _TagSystemRunnerState();
}

class _TagSystemRunnerState extends State<TagSystemRunner> {
  late TagSystemState state = TagSystemState(
    widget.tagSystem,
    Queue.of(widget.initialWord),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Removing ${state.system.m} letters per step'),
            Text('Alphabet:'),
            for (int i = 1; i <= state.system.nA; i++)
              Text('$i => ${state.system.p[i]!.join(',')}'),
            Text('Current state: ${state.word.join(',')}'),
            OutlinedButton(
              onPressed: state.isDone ? null : () => setState(state.step),
              child: Text('Step'),
            ),
            OutlinedButton(
              onPressed: () => setState(state.runToCompletion),
              child: Text('Run to completion'),
            ),
          ],
        ),
      ),
    );
  }
}
