import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'HangmanPage.dart';

class HangmanState extends State<HangmanPage> {
  Set<String> words = {};

  String? word;
  Set<String> letters = {};
  int errors = 0;

  var letterController = TextEditingController();

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/words');
  }

  void loadWords() {
    loadAsset(context).then((String w) {
      final List<String> lines = w.split('\n');
      final Set<String> words = Set<String>.from(lines);

      for (String word in words) {
        if (word.length < 3 || word.length > 10) {
          continue;
        }

        this.words.add(word);
      }

      print("Loaded ${words.length} words");
    });
  }

  void clear() {
    word = null;
    letters.clear();
    errors = 0;
  }

  void setWord(String word) {
    clear();
    this.word = word;

    setState(() {});
  }

  void chooseRandomWord() {
    setWord(words.elementAt(Random().nextInt(words.length)));
  }

  void chooseTypedWord() {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text("Type your word"),
              content: CupertinoTextField(
                autofocus: false,
                maxLength: 10,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                onSubmitted: (String word) {
                  setWord(word);
                  Navigator.of(context).pop();
                },
              ),
            ));
  }

  void chooseWord() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Choose a word'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Random'),
            onPressed: () {
              Navigator.pop(context);
              chooseRandomWord();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Type'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              chooseTypedWord();
            },
          ),
        ],
      ),
    );
  }

  String createFormattedWord() {
    if (word == null) {
      return "NO WORD";
    }

    final StringBuffer sb = StringBuffer();

    for (int i = 0; i < word!.length; i++) {
      if (letters.contains(word![i].toLowerCase()) || word![i] == ' ') {
        sb.write(word![i]);
      } else {
        sb.write('_');
      }
      sb.write(" ");
    }

    return sb.toString();
  }

  bool hasWon() {
    for (int i = 0; i < word!.length; i++) {
      if (letters.contains(word![i].toLowerCase()) || word![i] == ' ') {
        continue;
      } else {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: const EdgeInsets.all(10),
          child: const Text('New Game'),
          onPressed: () {
            chooseWord();
          },
        ),
        middle: const Text('Hangman'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/$errors.jpg'),
            ),
            Text(createFormattedWord(), style: const TextStyle(fontSize: 40)),
            const Padding(padding: EdgeInsets.all(8)),
            SizedBox(
                width: 100,
                child: CupertinoTextField(
                  padding: const EdgeInsets.all(16),
                  controller: letterController,
                  placeholder: 'Letter',
                  maxLength: 1,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (String letter) {
                    if (letter.length == 1 && word != null) {
                      if (word!.toLowerCase().contains(letter.toLowerCase())) {
                        letters.add(letter.toLowerCase());

                        if (hasWon()) {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) => CupertinoAlertDialog(
                              title: const Text('You won!'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  child: const Text('New word'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    chooseWord();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Exit'),
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        errors = min(errors + 1, 10);

                        if (errors >= 10) {
                          setState(() {
                            word = null;
                          });

                          showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                    title: const Text('Game Over'),
                                    actions: <CupertinoDialogAction>[
                                      CupertinoDialogAction(
                                        child: const Text('New Game'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          chooseWord();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text('Exit'),
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ));
                        }
                      }
                    }

                    letterController.clear();
                    setState(() {});
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadWords();
  }
}
